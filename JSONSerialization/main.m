//
//  main.m
//  JSONSerialization
//
//  Created by mac on 2023/6/13.
//

#import <Foundation/Foundation.h>
#import "JSONSerialization.h"


void test1(void){
    
    
    NSString * cwd = [NSString stringWithCString: getcwd(NULL,0) encoding:NSUTF8StringEncoding];
    NSData * data = [[NSData alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%@/key_word_search_v212.json",cwd]];
    
    NSString * jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    const char * cjson = [jsonString cStringUsingEncoding:NSUTF8StringEncoding];

    double t = 0.0;
    for(int i=0;i < 10000;i++) {
        double startTime = CFAbsoluteTimeGetCurrent();
        id idJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        double endTime = CFAbsoluteTimeGetCurrent();
        double s = (endTime - startTime) * 1000;
        t += s;
    }
    NSLog(@"OC原生%f",t/10000);

    t = 0.0;
    for(int i=0;i < 10000;i++) {
        double startTime = CFAbsoluteTimeGetCurrent();
        id idJSON = [JSONSerialization JSONObjectWithData:data error:NULL];
        double endTime = CFAbsoluteTimeGetCurrent();
        double s = (endTime - startTime) * 1000;
        t += s;
    }
    NSLog(@"OC自己实现%f",t/10000);
}


int main(int argc, const char * argv[]) {
    NSString * cwd = [NSString stringWithCString: getcwd(NULL,0) encoding:NSUTF8StringEncoding];
    NSData * data = [[NSData alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%@/key_word_search_v212有注释.json",cwd]];
    
    NSString * jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    id idJSON1 = [JSONSerialization JSONObjectWithData:data error:NULL];
    id idJSON2 = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingJSON5Allowed error:NULL];
    NSLog(@"%@",idJSON1);
    NSLog(@"%@",idJSON2);
    return 0;
}
/*
 */
