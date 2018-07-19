
#import <Foundation/Foundation.h>
#import "CRVideoProtocol.h"
#import "CRAdvancedRequestSupporterProtocol.h"
#import "CRAuthenticationDelegate.h"
@interface CRTwitch : NSObject <CRVideoProtocol, CRAdvancedRequestSupporterProtocol>
@property (weak, nonatomic) id target;


-(instancetype)initWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret redirectUri:(NSString *)redirectUri state:(NSString *)state;

-(instancetype)initWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;


-(void)useAdvancedAuthentication;
-(NSString *) saveAsString;
-(void) loadAsString:(NSString*) savedState;
-(void) setAuthDelegate:(id<CRAuthenticationDelegate>)delegate;
@end
