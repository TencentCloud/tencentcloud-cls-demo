

#import "ProducerExampleController.h"

@interface ProducerExampleController ()
@property(nonatomic, strong) UITextView *statusTextView;
@property(nonatomic, strong) LogProducerConfig *config;
@property(nonatomic, strong) LogProducerClient *client;

@end

@implementation ProducerExampleController

static ProducerExampleController *selfClzz;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selfClzz = self;
    self.title = @"基础配置";
    [self initViews];
    [self initLogProducer];
}

- (void) initViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self createLabel:@"参数: " andX:0 andY:0];

    DemoUtils *utils = [DemoUtils sharedInstance];
    NSString *parameters = [NSString stringWithFormat:@"endpoint: %@\ntopic: %@\naccessKeyId: %@\naccesskeySecret: %@\n",
                            utils.endpoint,
                            utils.topic,
                            utils.accessKeyId,
                            utils.accessKeySecret];
    
    UILabel *label = [self createLabel:parameters andX:0 andY:SLCellHeight andWidth:CLScreenW - SLPadding * 2 andHeight:SLCellHeight * 5];
    label.numberOfLines = 0;
    [label sizeToFit];
    label.textAlignment = NSTextAlignmentLeft;
    
    [self createLabel:@"状态: " andX:0 andY:SLCellHeight * 5];
    
    self.statusTextView = [self createTextView:@"" andX:0 andY:SLCellHeight * 6 andWidth:(CLScreenW - SLPadding * 2) andHeight:(SLCellHeight * 4)];
    self.statusTextView.textAlignment = NSTextAlignmentLeft;
    self.statusTextView.layoutManager.allowsNonContiguousLayout = NO;
    [self.statusTextView setEditable:NO];
    [self.statusTextView setContentOffset:CGPointMake(0, 0)];
    
    [self createButton:@"发送" andAction:@selector(send) andX:((CLScreenW - SLPadding * 2 - SLCellWidth) / 2) andY:SLCellHeight * 11];
}

- (void) updateStatus: (NSString *)append {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *status = [NSString stringWithFormat:@"%@\n> %@", self.statusTextView.text, append];
        [self.statusTextView setText:status];
        [self.statusTextView scrollRangeToVisible:NSMakeRange(self->_statusTextView.text.length, 1)];
    });
}

- (void) send {
    LogProducerResult result = [_client AddLog:[self oneLog]];
    CLSLogV(@"addlog result: %ld", result);
    [self updateStatus:[NSString stringWithFormat:@"addlog result: %ld", result]];
}

static void _on_log_send_done(const char * config_name, log_producer_result result, size_t log_bytes, size_t compressed_bytes, const char * req_id, const char * message, const unsigned char * raw_buffer, void * userparams) {
    if (result == LOG_PRODUCER_OK) {
        NSString *success = [NSString stringWithFormat:@"send success, topic : %s, result : %d, log bytes : %d, compressed bytes : %d, request id : %s", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id];
        CLSLogV("%@", success);
        
        [selfClzz updateStatus:success];
    } else {
        NSString *fail = [NSString stringWithFormat:@"send fail   , topic : %s, result : %d, log bytes : %d, compressed bytes : %d, request id : %s, error message : %s", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id, message];
        CLSLogV("%@", fail);
        
        [selfClzz updateStatus:fail];
    }
}

- (void) initLogProducer {
    DemoUtils *utils = [DemoUtils sharedInstance];

    _config = [[LogProducerConfig alloc] initWithEndpoint:[utils endpoint] accessKeyID:[utils accessKeyId] accessKeySecret:[utils accessKeySecret]];
    [_config SetTopic:utils.topic];
    [_config SetPacketLogBytes:1024*1024];
    [_config SetPacketLogCount:1024];
    [_config SetPacketTimeout:3000];
    [_config SetMaxBufferLimit:64*1024*1024];
    [_config SetSendThreadCount:1];
    [_config SetConnectTimeoutSec:10];
    [_config SetSendTimeoutSec:10];
    [_config SetDestroyFlusherWaitSec:1];
    [_config SetDestroySenderWaitSec:1];
    [_config SetCompressType:0];

    _client = [[LogProducerClient alloc] initWithLogProducerConfig:_config callback:_on_log_send_done];
}


- (Log *) oneLog {
    Log* log = [[Log alloc] init];

    [log PutContent:@"content_key_1" value:@"1abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+"];
    [log PutContent:@"content_key_2" value:@"2abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_3" value:@"3abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_4" value:@"4abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_5" value:@"5abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_6" value:@"6abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_7" value:@"7abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_8" value:@"8abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_9" value:@"9abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content" value:@"中文"];

    return log;
}


@end
