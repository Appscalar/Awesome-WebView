#import "Settings.h"
#import "Connectivity.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation Connectivity

- (BOOL) isConnected {
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                if (SHOW_CONNECTIVITY_DEBUG_MSG){
                    NSLog(@"[Connectivity] You broke the internet :(");
                }
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                if (SHOW_CONNECTIVITY_DEBUG_MSG){
                    NSLog(@"[Connectivity] W00T INTERWEBS!!!!!! \\(^-^)/");
                }
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    if (SHOW_CONNECTIVITY_DEBUG_MSG){
                        NSLog(@"[Connectivity] W00T INTERWEBS!!!!!! \\(^-^)/");
                    }
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                if (SHOW_CONNECTIVITY_DEBUG_MSG){
                    NSLog(@"[Connectivity] W00T INTERWEBS!!!!!! \\(^-^)/");
                }
                return YES;
            }
        }
    }
    
    if (SHOW_CONNECTIVITY_DEBUG_MSG){
        NSLog(@"[Connectivity] You broke the internet :(");
    }
    
    return NO;
}

@end
