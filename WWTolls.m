

#import <Security/Security.h>
#include <sys/sysctl.h>
#import <CommonCrypto/CommonDigest.h>
#include "sys/types.h"
#include "sys/sysctl.h"

#import "WWTolls.h"
#import "SSKeychain.h"
#import "KeychainItemWrapper.h"
#import "Define.h"
#import "NSDictionary+NARSafeDictionary.h"

static NSMutableDictionary *allRecodDic;
static NSMutableDictionary *allArrayDic;
static KeychainItemWrapper *wrapper;

@implementation WWTolls

+(UIColor *) colorWithHexString: (NSString *) stringToConvert  //@"#5a5a5a"
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    
    NSRange range;
    
    range.location = 0;
    
    range.length = 2;
    
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
            
                           green:((float) g / 255.0f)
            
                            blue:((float) b / 255.0f)
            
                           alpha:1.0f];
    
}

+ (NSString*)getDeviceVersion
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+(NSString*)writeUniversallyUniqueIdentifier;
{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);

    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *userUUIDPath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",DOCUMENT_USER_UUID]];
    NSMutableDictionary *textDictionary = [[NSMutableDictionary alloc]initWithContentsOfFile:userUUIDPath];
    if ( [NSString stringWithFormat:@"%@",[textDictionary objectForKey:@"UUID"]].length==0 || textDictionary==nil) {
            NSMutableDictionary *UUIDdictionary = [[NSMutableDictionary alloc]initWithCapacity:1];
            [UUIDdictionary setObject:result forKey:@"UUID"];
            [UUIDdictionary writeToFile:userUUIDPath atomically:YES];
        return [UUIDdictionary objectForKey:@"UUID"];
    };
    return [textDictionary objectForKey:@"UUID"];
   //     Team identifier == LME682U793.//keychain调用方法
//        wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Account Number"
//                                                      accessGroup:@"YOUR_APP_ID_HERE.com.yourcompany.GenericKeychainSuite"];
//    if ([NSString stringWithFormat:@"%@",[wrapper objectForKey:(__bridge id)kSecValueData]].length==0) {
//        //保存数据
//        [wrapper setObject:result forKey:(__bridge id)kSecValueData];
//    }
}

+(NSString*)getUniversallUniqueIdentifier{
    NSString *universallUniqueIdentifier = [wrapper objectForKey:(__bridge id)kSecValueData];
    return universallUniqueIdentifier;
}

+(BOOL)setLocalArrayPlistInfo:(NSMutableArray *)postMutableArray pathString:(NSString*)pathStr Key:(NSString*)key
{
    NSArray *DocumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [DocumentPaths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",pathStr]];
    NSLog(@"保存用户信息的路径=========%@",filePath);
    if (allArrayDic == nil) {
        allArrayDic = [[NSMutableDictionary alloc] initWithCapacity:1];
    }

    if (postMutableArray.count!=0) {
        [allArrayDic setObject:postMutableArray forKey:key];
    }

    //NSLog(@"打印用户信息*****%@",allArrayDic);
    //将字典写入plist文件中.
    BOOL result = false;
    if (allArrayDic==nil && (![allArrayDic isKindOfClass:[NSMutableDictionary class]])) {
        return false;
    }else{
//        [allArrayDic writeToFile:filePath atomically:YES];
    }
    return result;
}
//**************************************************************************************//
+(BOOL)setMyLocalPlistInfo:(id)postObject andFilePath:(NSString*)myFilePath
{
    NSArray *DocumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [DocumentPaths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",myFilePath]];
    NSLog(@"保存用户信息的路径=========%@",filePath);
    NSLog(@"打印用户信息*****%@",postObject);
    //将字典写入plist文件中.
    BOOL result = false;
    result =[postObject writeToFile:filePath atomically:YES];
    return result;
}

+(id)getMyPostListFilePathString:(NSString*)pathString;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",pathString]];
    NSLog(@"-myObject--------------%@",filePath);

    id myObject;

    myObject = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];

    if (myObject==nil || (![myObject isKindOfClass:[NSMutableDictionary class]])) {
        myObject = [[NSMutableArray alloc]initWithContentsOfFile:filePath];
    }
        NSLog(@"-myObject--------------%@",myObject);
    return myObject;
}
//**************************************************************************************//
+(BOOL)setLocalPlistInfo:(NSMutableDictionary *)postDictionary Key:(NSString*)key
{
    NSArray *DocumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [DocumentPaths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",DOCUMENT_USER_PLIST]];
        NSLog(@"保存用户信息的路径=========%@",filePath);
    if (allRecodDic == nil) {
        allRecodDic = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    [allRecodDic setObject:postDictionary forKey:key];
           NSLog(@"打印用户信息*****%@",allRecodDic);
    //将字典写入plist文件中.
    BOOL result = false;
    result =[allRecodDic writeToFile:filePath atomically:YES];
    return result;
}

+(NSMutableDictionary *)getPostList:(NSString *)key andPathString:(NSString*)pathString;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",pathString]];
//    DOCUMENT_USER_PLIST
//    NSLog(@"本地Dictionary=========%@",allRecodDic);
    allRecodDic = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    NSLog(@"allPostDic=========%@",filePath);
    NSMutableDictionary *Dictionary = [allRecodDic objectForKey:key];
//    NSLog(@"本地Dictionary=========%@",allRecodDic);
    return Dictionary;
}

+(NSMutableArray *)getArrayPostList:(NSString *)key andPathString:(NSString*)pathString;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",pathString]];
    //    DOCUMENT_USER_PLIST
    //    NSLog(@"本地Dictionary=========%@",allRecodDic);
    NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    NSLog(@"allPostDic=========%@",myDictionary);
    NSMutableArray *myArray = [myDictionary objectForKey:key];
        NSLog(@"本地myArray=========%@",myArray);
    return myArray;
}

+(void)removePostList:(NSString*)key{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",DOCUMENT_USER_PLIST]];

    allRecodDic = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];

    NSMutableDictionary *Dictionary = [allRecodDic objectForKey:key];

    [Dictionary removeAllObjects];

    [Dictionary writeToFile:filePath atomically:YES];
}

+(NSString *) fileSizeAtPath:(NSString*) filePath{

    NSFileManager* manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *file_Path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",DOCUMENT_USER_PLIST]];
     NSLog(@"**********%f",[[manager attributesOfItemAtPath:file_Path error:nil] fileSize]/(1024.0*1024.0));
    if ([manager fileExistsAtPath:file_Path]){

        if (([[manager attributesOfItemAtPath:file_Path error:nil] fileSize]/(1024.0*1024.0))>1) {
            return [NSString stringWithFormat:@"%.1fM",[[manager attributesOfItemAtPath:file_Path error:nil] fileSize]/(1024.0*1024.0)];
        }else{
            return [NSString stringWithFormat:@"%.1fKB",[[manager attributesOfItemAtPath:file_Path error:nil] fileSize]/(1024.0)];
        }
    }
    return [NSString stringWithFormat:@"0KB"];
}

+(NSString*)getkeyChain{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *bundleId = [info objectForKey:@"CFBundleIdentifier"];
    /** 初始化一个保存用户帐号的KeychainItemWrapper **/
    NSString *UUID = [SSKeychain passwordForService:bundleId account:bundleId];
    if (UUID == nil || UUID.length == 0) {
        UUID = [[NSUUID UUID] UUIDString];
        [SSKeychain setPassword:UUID forService:bundleId account:bundleId];
        return UUID;
    }
    return UUID;
}

+(NSMutableData*)getJsonData:(NSMutableDictionary*)dictionary{
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSMutableData *stringMutableData = [NSMutableData dataWithData:stringData];
    return stringMutableData;
}

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (unsigned)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+(BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189,177
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-9]|8[0-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[0-9])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189,177
     22         */
    NSString * CT = @"^1((33|47|79|45|70|77|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";

    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];

    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//压缩图片
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);

    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];

    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();

    // End the context
    UIGraphicsEndImageContext();

    // Return the new image.
    return newImage;
}

+(NSString*)timeString:(NSString*)inputTime{

    NSString* timeString = [NSString stringWithFormat:@"%@",inputTime];

    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];

    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate* inputDate = [inputFormatter dateFromString:timeString];

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];

    [outputFormatter setDateFormat:@"MM月dd日"];

    NSString *str = [outputFormatter stringFromDate:inputDate];

    return str;
}

+(NSString*)timeString2:(NSString*)inputTime;
{

    NSString* timeString = [NSString stringWithFormat:@"%@",inputTime];

    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];

    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate* inputDate = [inputFormatter dateFromString:timeString];

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];

    [outputFormatter setDateFormat:@"MM月dd日 HH:mm"];

    NSString *str = [outputFormatter stringFromDate:inputDate];
    
    return str;

}

+(NSString*)timeString3:(NSString*)inputTime;
{

    NSString* timeString = [NSString stringWithFormat:@"%@",inputTime];

    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];

    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate* inputDate = [inputFormatter dateFromString:timeString];

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];

    [outputFormatter setDateFormat:@"yyyy-MM-dd"];

    NSString *str = [outputFormatter stringFromDate:inputDate];
    
    return str;

}
+(NSString*)timeString4:(NSString*)inputTime{
    
    NSString* timeString = [NSString stringWithFormat:@"%@",inputTime];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate* inputDate = [inputFormatter dateFromString:timeString];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    [outputFormatter setDateFormat:@"yy.MM.dd"];
    
    NSString *str = [outputFormatter stringFromDate:inputDate];
    if ([[str substringToIndex:2] isEqualToString:@"15"]) {
        str = [str substringFromIndex:3];
    }
    return str;
}
#pragma mark - Date and Time -
+(NSString*)date:(NSString*)dateStr
{

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fromdate=[format dateFromString:dateStr];
    NSTimeZone *fromzone = [NSTimeZone systemTimeZone];
    NSInteger frominterval = [fromzone secondsFromGMTForDate: fromdate];
    NSDate *fromDate = [fromdate  dateByAddingTimeInterval: frominterval];
    //    NSLog(@"fromdate=%@",fromDate);
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    //    NSLog(@"enddate=%@",localeDate);
    NSDateComponents *components = [gregorian components:unitFlags fromDate:fromDate toDate:localeDate options:0];

    NSInteger minute = [components minute];
    NSInteger hour = [components hour];
    NSInteger months = [components month];
    NSInteger days = [components day];
    NSInteger year = [components year];

    NSString *srt;

    if (months==0&&days==0&&hour==0&&minute==0) {

        srt=[NSString stringWithFormat:@"1分钟前"];

    }
    if (months==0&&days==0&&hour==0) {
        if (minute==0) {
            srt=[NSString stringWithFormat:@"刚刚发布"];
        }else{
            srt=[NSString stringWithFormat:@"%ld分钟前",(long)minute];
        }
    }else if(months==0&&days==0){

        srt=[NSString stringWithFormat:@"%ld小时前",(long)hour];
    }
    else if (months==0&&days<31)
    {
        srt=[NSString stringWithFormat:@"%ld天前",(long)days];
    }
    else if(year==0&&months<12){
        srt = [NSString stringWithFormat:@"%ld月前",(long)months];
    }
    else{
        srt=@"1年前";
    }
    return srt;
}

+(NSString*)configureTimeString:(NSString*)inputTime andStringType:(NSString*)myType{

    NSString* timeString = [NSString stringWithFormat:@"%@",inputTime];

    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];

    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate* inputDate = [inputFormatter dateFromString:timeString];

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];

    [outputFormatter setDateFormat:myType];

    NSString *str = [outputFormatter stringFromDate:inputDate];
    
    return str;
}

-(void)dealloc
{
    allArrayDic = nil;
}


+ (float) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    return sizeToFit.height;
}

@end
