//
// Created by Jiang Lu on 14-4-1.
// Copyright (C) 2013-2014, Infthink (Beijing) Technology Co., Ltd.
//

#import <Foundation/Foundation.h>

/**
 * An invalid request ID; if a method returns this request ID, it means that the request could
 * not be made.
 */
extern const NSInteger kMSFKInvalidRequestID;

/**
 * A MSFKFlingChannel is used to send and receive messages that are tagged with a specific
 * namespace. In this way, multiple channels may be multiplexed over a single connection
 * to the device.
 * <p>
 * Subclasses should implement the @link MSFKFlingChannel#didReceiveTextMessage: @endlink and/or
 * @link MSFKFlingChannel#didReceiveBinaryMessage: @endlink methods to process incoming messages,
 * and will typically provide additional methods for sending messages that are specific to a
 * given namespace.
 *
 * @ingroup Messages
 */
@interface MSFKFlingChannel : NSObject

/** The channel's namespace. */
@property(nonatomic, copy) NSString *protocolNamespace;

@property(nonatomic) BOOL isConnected;

@property(nonatomic) id handler;

/**
 * Designated initializer. Constructs a new MSFKFlingChannel with the given namespace.
 *
 * @param protocolNamespace The namespace.
 */
- (id)initWithNamespace:(NSString *)protocolNamespace;

/**
 * Called when a text message has been received for this channel.
 * The default implementation is a no-op.
 *
 * @param message The message string.
 */
- (void)didReceiveTextMessage:(NSString *)textMessage;

/**
 * Sends a text message.
 *
 * @param message The message string.
 * @return <code>YES</code> on success or <code>NO</code> if the message could not be sent (because
 * the handler is not connected, or because the send buffer is too full at the moment).
 */
- (BOOL)sendTextMessage:(NSString *)textMessage;

/**
 * Generates a request ID for a new message.
 */
- (NSInteger)generateRequestID;

/**
 * A convenience method which wraps generateRequestID in an NSNumber.
 */
- (NSNumber *)generateRequestNumber;

/**
 * Called when this channel is added to a connected handler, or when then disconnected
 * handler to which this channel has been added becomes connected.
 *
 * This implementation updates isConnected, so if subclasses override this method they should
 * call through to the super implementation.
 */
- (void)didConnect;

/**
 * Called when this channel is removed from a connected handler, or when then connected
 * handler to which this channel has been added becomes disconnected.
 *
 * This implementation updates isConnected, so if subclasses override this method they should
 * call through to the super implementation.
 */
- (void)didDisconnect;

- (NSString *)description;

@end