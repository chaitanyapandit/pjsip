/*
 * Copyright (C) 2014 Xianwen Chen <xianwen@xianwenchen.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#import "XCPjsua.h"

#import <pjsua-lib/pjsua.h>

#define THIS_FILE "XCPjsua.c"

const size_t MAX_SIP_ID_LENGTH = 50;
const size_t MAX_SIP_REG_URI_LENGTH = 50;

static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata);
static void on_call_state(pjsua_call_id call_id, pjsip_event *e);
static void on_call_media_state(pjsua_call_id call_id);
static void on_reg_state2(pjsua_acc_id acc_id, pjsua_reg_info *info);
static void error_exit(const char *title, pj_status_t status);

@interface XCPjsua ()
{
    pjsua_call_id callID;
}


@end

@implementation XCPjsua
{
    pjsua_acc_id _acc_id;
    BOOL isIncoming;
}

+ (XCPjsua *)sharedXCPjsua
{
    static XCPjsua *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[XCPjsua alloc] init];
    });
    return sharedInstance;
}

- (void)addUser:(char *)sipUser withPassword:(char *)password {
    
    pjsua_acc_id newAccoutnId;

    pj_status_t status;
    pjsua_transport_id *tp;
    pjsua_transport_get_info(*tp, 0);
    
    pjsua_acc_config cfg;
    cfg.cred_count = 2;
    cfg.cred_info[1].scheme = pj_str("digest");
    cfg.cred_info[1].realm = pj_str("107.170.46.82");
    cfg.cred_info[1].username = pj_str(sipUser);
    cfg.cred_info[1].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    cfg.cred_info[1].data = pj_str(password);
    
    status = pjsua_acc_add(&cfg, PJ_TRUE, &newAccoutnId);
    
    NSLog(@"");
}

- (int)startPjsipAndRegisterOnServer:(char *)sipDomain
                        withUserName:(char *)sipUser
                         andPassword:(char *)password
                            callback:(RegisterCallBack)callback
{
    pj_status_t status;
    // Create pjsua first
    status = pjsua_create();
    if (status != PJ_SUCCESS) error_exit("Error in pjsua_create()", status);
    
    // Init pjsua
    {
        // Init the config structure
        pjsua_config cfg;
        pjsua_config_default (&cfg);
        
    
        
        cfg.cb.on_incoming_call = &on_incoming_call;
        cfg.cb.on_call_media_state = &on_call_media_state;
        cfg.cb.on_call_state = &on_call_state;
        cfg.cb.on_reg_state2 = &on_reg_state2;
        
        // Init the logging config structure
        pjsua_logging_config log_cfg;
        pjsua_logging_config_default(&log_cfg);
        log_cfg.console_level = 4;
        
        // Init the pjsua
        status = pjsua_init(&cfg, &log_cfg, NULL);
        if (status != PJ_SUCCESS) error_exit("Error in pjsua_init()", status);
    }
//    
    // Add UDP transport.
    {
        // Init transport config structure
        pjsua_transport_config cfg;
        pjsua_transport_config_default(&cfg);
//        cfg.port = 5080;
        
        // Add UDP transport.
        status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &cfg, NULL);
        if (status != PJ_SUCCESS) error_exit("Error creating transport", status);
    }
    
    // Add TCP transport.
    {
        // Init transport config structure
        pjsua_transport_config cfg;
        pjsua_transport_config_default(&cfg);
//        cfg.port = 5080;
        
        // Add TCP transport.
        status = pjsua_transport_create(PJSIP_TRANSPORT_TCP, &cfg, NULL);
        if (status != PJ_SUCCESS) error_exit("Error creating transport", status);
    }
    
    // Initialization is done, now start pjsua
    status = pjsua_start();
    if (status != PJ_SUCCESS) error_exit("Error starting pjsua", status);
    
    // Register the account on local sip server
    {
        pjsua_acc_config cfg;
        
        pjsua_acc_config_default(&cfg);
        
        // Account ID
        char sipId[MAX_SIP_ID_LENGTH];
        sprintf(sipId, "sip:%s@%s", sipUser, sipDomain);
        cfg.id = pj_str(sipId);
    
        // Reg URI
        char regUri[MAX_SIP_REG_URI_LENGTH];
        //char sip_proxy[MAX_SIP_ID_LENGTH];
        
        NSString * tpStr = @";transport=TCP";
        
        sprintf(regUri, "sip:%s%s", sipDomain,[tpStr UTF8String]);
        cfg.reg_uri = pj_str(regUri);

        
//        cfg.outbound_proxy[0] = pj_str(sip_proxy);
//        cfg.outbound_proxy_cnt = 1;
        
        
        // Account cred info
        cfg.cred_count = 1;
        cfg.cred_info[0].scheme = pj_str("digest");
        cfg.cred_info[0].realm = pj_str(sipDomain);
        cfg.cred_info[0].username = pj_str(sipUser);
        cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
        cfg.cred_info[0].data = pj_str(password);
        
        status = pjsua_acc_add(&cfg, PJ_TRUE, &_acc_id);
        if (status != PJ_SUCCESS) error_exit("Error adding account", status);
    }
    
    self.registerCallBack = callback;

    return 0;
}

- (void)makeCallTo:(char*)destUri
{
    pj_status_t status;
    
//    status = pjsua_detect_nat_type();
//    if (status != PJ_SUCCESS)
//        error_exit("NAT DETECTED>!!!!!!!", status);

    
    pj_str_t uri = pj_str(destUri);
    
    status = pjsua_call_make_call(_acc_id, &uri, 0, NULL, NULL, NULL);
    
    if (status != PJ_SUCCESS)
        error_exit("Error making call", status);
}

-(void)callAnswer:(NSInteger)calId
{
    pjsua_call_info ci;
    
    int call_ID = (int)calId;
    
    pjsua_call_get_info(call_ID, &ci);
    
    PJ_LOG(3,(THIS_FILE, "Incoming call from %.*s!!",
              (int)ci.remote_info.slen,
              ci.remote_info.ptr));
    
    //    /* Automatically answer incoming calls with 200/OK */
        pjsua_call_answer(call_ID, 200, NULL, NULL);
}

-(void)callDecline
{
    pjsua_call_info ci;
    
    int call_ID = (int)ci.call_id.ptr;
    
    pjsua_call_get_info(call_ID, &ci);
    
    PJ_LOG(3,(THIS_FILE, "Incoming call from %.*s!!",
              (int)ci.remote_info.slen,
              ci.remote_info.ptr));
    
    //    /* Automatically answer incoming calls with 200/OK */
    pjsua_call_answer(call_ID, 400, NULL, NULL);
}

-(void)destroy
{
    pjsua_destroy2(PJSUA_DESTROY_NO_RX_MSG);
}

- (void)endCall
{
    pjsua_call_hangup_all();
}

- (void)handleRegistrationStateChangeWithRegInfo: (pjsua_reg_info *)info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (info->cbparam->code)
        {
            case 200:
                // register success
                self.registerCallBack(YES);
                break;
            case 401:
                // illegal credential
                self.registerCallBack(NO);
                break;
            default:
                break;
        }
    });
}

@end

/* Callback called by the library when registration state has changed */
static void on_reg_state2(pjsua_acc_id acc_id, pjsua_reg_info *info)
{
    [[XCPjsua sharedXCPjsua] handleRegistrationStateChangeWithRegInfo: info];
}

/* Callback called by the library upon receiving incoming call */
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id,
                             pjsip_rx_data *rdata)
{
    pjsua_call_info ci;
    
    PJ_UNUSED_ARG(acc_id);
    PJ_UNUSED_ARG(rdata);
    
    pjsua_call_get_info(call_id, &ci);
    
    
    NSNumber *caller = [NSNumber numberWithInt:call_id];
    NSString * str = [NSString stringWithFormat:@"You have a call from %s",ci.remote_info.ptr];
    NSMutableDictionary * info = [[NSMutableDictionary alloc]initWithObjectsAndKeys:caller, @"callerID", str, @"callerName", nil];
    
    PJ_LOG(3,(THIS_FILE, "Incoming call from %.*s!!",
              (int)ci.remote_info.slen,
              ci.remote_info.ptr));
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"incoming" object:info];
    
//    /* Automatically answer incoming calls with 200/OK */
//    pjsua_call_answer(call_id, 200, NULL, NULL);
}


/* Callback called by the library when call's state has changed */
static void on_call_state(pjsua_call_id call_id, pjsip_event *e)
{
    pjsua_call_info ci;
    
    PJ_UNUSED_ARG(e);
    
    pjsua_call_get_info(call_id, &ci);
    
    PJ_LOG(3,(THIS_FILE, "Call %d state=%.*s", call_id,
              (int)ci.state_text.slen,
              ci.state_text.ptr));
    
    if (ci.state == PJSIP_INV_STATE_CALLING)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"calling" object:nil];
    }
    if (ci.state == PJSIP_INV_STATE_INCOMING)
    {
    }
    if (ci.state == PJSIP_INV_STATE_CONNECTING)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connected" object:nil];
    }
    if (ci.state == PJSIP_INV_STATE_CONFIRMED)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"confirmed" object:nil];
    }
    if (ci.state == PJSIP_INV_STATE_DISCONNECTED)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnected" object:nil];
    }
}

/* Callback called by the library when call's media state has changed */
static void on_call_media_state(pjsua_call_id call_id)
{
    pjsua_call_info ci;

    pjsua_call_get_info(call_id, &ci);
//    pjsua_call_setting setting = ci.setting;
    
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE)
    {
        // When media is active, connect call to sound device.
        
        
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
        
//        if (ci.state == PJSIP_INV_STATE_INCOMING)
//        {
//            pjsua_conf_adjust_rx_level(ci.conf_slot,1);
//            pjsua_conf_adjust_tx_level(ci.conf_slot,0);
//        }
    }
}

/* Display error and exit application */
static void error_exit(const char *title, pj_status_t status)
{
    pjsua_perror(THIS_FILE, title, status);
    pjsua_destroy();
    exit(1);
}
