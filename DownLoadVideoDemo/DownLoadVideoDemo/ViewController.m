//
//  ViewController.m
//  DownLoadVideoDemo
//
//  Created by 朱佳男 on 2017/2/8.
//  Copyright © 2017年 JiaNanKeJi. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<NSURLSessionDelegate,NSURLSessionDownloadDelegate>
//下载任务
@property (nonatomic, strong)NSURLSessionDownloadTask *downTask;

//网络会话
@property (nonatomic, strong)NSURLSession * downLoadSession;
@end

@implementation ViewController
NSString * const downloadUrl1 = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)downLoadButtonClick:(id)sender {
    //参数设置类  简单的网络下载使用defaultSessionConfiguration即可
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //创建网络会话
    self.downLoadSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue new]];
    
    
    //数据请求
    /*
     *@param URL 资源url
     *@param timeoutInterval 超时时长
     */
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl1] cachePolicy:5 timeoutInterval:60.f];
    
    //创建下载任务
    self.downTask = [self.downLoadSession downloadTaskWithRequest:imgRequest];
    
    //启动下载任务
    [self.downTask resume];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //获取下载进度
    double currentProgress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //进行UI操作  设置进度条
        
        self.progressView.progress = currentProgress;
        
    });
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@" function == %s, line == %d, error ==  %@",__FUNCTION__,__LINE__,error);
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    //存储本地
    
    //1.获取Documents文件夹路径 （不要将视频、音频等较大资源存储在Caches路径下）
//    *方法一
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    
//    *方法二
    NSFileManager *manager = [NSFileManager defaultManager];
//    NSURL * documentsDirectory = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    
    //2.创建资源存储路径
    NSString *appendPath = [NSString stringWithFormat:@"/new2.mp4"];
    NSString *file = [documentsPath stringByAppendingString:appendPath];
    
    //3.将下载好的视频资源存储在路径下
    
    //删除之前相同路径的文件
    [manager removeItemAtPath:file error:nil];
    
    //将视频资源从原有路径移动到自己指定的路径
    BOOL success = [manager copyItemAtPath:location.path toPath:file error:nil];
    
    if (success) {
        UISaveVideoAtPathToSavedPhotosAlbum(file, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        //回到主线程进行本地视频播放
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //创建视频播放的本地路径
            
//            *** 请使用此方法创建本地路径
            NSURL *url = [[NSURL alloc]initFileURLWithPath:file];
            
//            *** 此方法创建的路径无法播放 不是一个完整的路径
            //NSURL *url2 = [[NSURL alloc]initWithString:file];
            
            //系统的视频播放器
            AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
            //播放器的播放类
            AVPlayer * player = [[AVPlayer alloc]initWithURL:url];
            
            controller.player = player;
            //自动开始播放
            [controller.player play];
            //推出视屏播放器
            [self presentViewController:controller animated:YES completion:nil];
            
        });
    }
}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInf{
    NSLog(@"存储成功");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
