
#import "LogProducerClient+Bricks.h"

@interface LogProducerClient (Bricks)
@property (nonatomic, assign) bool enableTrack;
@end

@implementation LogProducerClient (Bricks)


- (void)setEnableTrack:(bool)enable {
    self->_enableTrack = enable;
}

- (bool)enableTrack {
    return self->_enableTrack;
}

@end
