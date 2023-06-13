//
//  JSONSerialization.m
//  JSONSerialization
//
//  Created by mac on 2023/6/13.
//
#import "JSONSerialization.h"
static inline bool inRange(char value,char lower,char upper){
    return value >= lower && value <= upper;
}
static bool compare(const char *cjson,int index,int length,const char *substring){
    for(int i=0;i<length;i++) {
        char c = *(cjson + index + i);
        if( c == *(substring + i)) {
            continue;;
        }else{
            return false;
        }
    }
    return true;
}
static void skipWhiteSpace(const char *cjson,int *index){
    while (*(cjson + *index) == ' ' || *(cjson + *index) == '\n' || *(cjson + *index) == '\r' || *(cjson + *index) == '\t') {
        *index += 1;
    }
    if (*(cjson + *index) == '/' && *(cjson + *index + 1) == '/') {
        *index += 2;
        while (*(cjson + *index) != '\n'){
            *index += 1;
        }
        skipWhiteSpace(cjson,index);
    }else if (*(cjson + *index) == '/' && *(cjson + *index + 1) == '*') {
        *index += 2;
        while (*(cjson + *index) != '*' && *(cjson + *index + 1) != '/'){
            *index += 1;
        }
        *index += 2;
        skipWhiteSpace(cjson,index);
    }
}
static NSString * substr(const char *cjson,int index,int length){
    if(length <= 0){
        return  @"";
    }
    char tempStr[length+1];
    memset(tempStr, '\0', length+1);
    for(int i=0;i < length;i++) {
        tempStr[i] = *(cjson + index + i);
    }
    return [NSString stringWithCString:tempStr encoding:NSUTF8StringEncoding];
}
@implementation JSONSerialization{
    int _index;
    const char * _cjson;
}
+(id)JSONObjectWithData:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error{
    return [self JSONObjectWithcString:data.bytes error:error];
}
+(id)JSONObjectWithcString:(const char *)cjson error:(NSError *__autoreleasing  _Nullable *)error{
    JSONSerialization * serialization = JSONSerialization.new;
    serialization->_index = 0;
    serialization->_cjson = cjson;
    @try {
        return [serialization parse];
    } @catch (NSException *exception) {
        NSError * tempError = [NSError errorWithDomain:exception.reason code:-1 userInfo:NULL];
        if (error) {
            *error = tempError;
        }
    }
    return nil;
}
+(id)JSONObjectWithString:(NSString *)json error:(NSError *__autoreleasing  _Nullable *)error{
    return [self JSONObjectWithcString: [json cStringUsingEncoding:NSUTF8StringEncoding] error:error];
}
-(id)parse{
    skipWhiteSpace(_cjson, &_index);
    char token = *(_cjson + _index);
    switch (token) {
        case 'n':
            return [self parseNull];
        case 't':
        case 'f':
            return [NSNumber numberWithBool:[self parseBool]];
        case '-':
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            return [self parseNumber];
        case '"':
            return [self parseString];
        case '[':
            return [self parseArray];
        case '{':
            return [self parseObject];
        default:
            break;
    }
    @throw [NSException exceptionWithName:@"JSONSerializationException" reason:@"无效的JSON字符串" userInfo:nil];
}
-(NSNumber *)parseNumber{
    size_t pos = _index;
    if (*(_cjson + _index) == '-') {
        _index += 1;
    }
    while (inRange(*(_cjson + _index),'0','9') || *(_cjson + _index) == 'e' || *(_cjson + _index) == 'E'){
        _index += 1;
    }
    if (*(_cjson + _index) == '.') {
        _index += 1;
        while (inRange(*(_cjson + _index),'0','9') || *(_cjson + _index) == 'e' || *(_cjson + _index) == 'E'){
            _index += 1;
        }
        double v = atof(_cjson + pos);
        return [NSNumber numberWithDouble:v];
    }
    return [NSNumber numberWithInt:atoi(_cjson + pos)];
}
-(NSNull *)parseNull{
    if (compare(_cjson, _index, 4, "null")) {
        _index += 4;
        return  NSNull.null;
    }
    @throw [NSException exceptionWithName:@"JSONSerializationException" reason:@"JSON解析Null出错" userInfo:nil];
}
-(BOOL)parseBool{
    
    if (compare(_cjson, _index, 4, "true")) {
        _index += 4;
        return true;
    }else if (compare(_cjson, _index, 5, "false")){
        _index += 5;
        return false;
    }
    @throw [NSException exceptionWithName:@"JSONSerializationException" reason:@"JSON解析Bool出错" userInfo:nil];
}
-(NSString *)parseString{
    int pos = _index + 1;
    while (*(_cjson + _index) != '\0') {
        _index += 1;
        if (*(_cjson + _index) == '"' && *(_cjson + _index - 1) != '\\') {
            break;
        }
    }
    NSString * value = substr(_cjson, pos, _index - pos);
    _index += 1;
    return  value;
}

-(NSDictionary *)parseObject{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    skipWhiteSpace(_cjson, &_index);
    _index += 1;
    skipWhiteSpace(_cjson, &_index);
    if(*(_cjson + _index) == '}'){
        return dict.copy;
    }
    if(*(_cjson + _index) != '"'){
        @throw [NSException exceptionWithName:@"JSONSerializationException" reason:@"JSON解析Object出错" userInfo:nil];
    }
    while (true) {
        NSString * key = [self parseString];
        if(key==nil){
            return nil;
        }
        skipWhiteSpace(_cjson, &_index);
        if(*(_cjson + _index) != ':'){
            @throw [NSException exceptionWithName:@"JSONSerializationException" reason:@"JSON解析Object出错" userInfo:nil];
        }
        _index += 1;
        skipWhiteSpace(_cjson, &_index);
        id value = [self parse];
        skipWhiteSpace(_cjson, &_index);
        if(*(_cjson + _index) == '}'){
            break;
        }
        if(*(_cjson + _index) != ','){
            @throw [NSException exceptionWithName:@"JSONSerializationException" reason:@"JSON解析Object出错" userInfo:nil];
        }
        dict[key] = value;
        _index += 1;
        skipWhiteSpace(_cjson, &_index);
    }
    _index += 1;
    return dict;
}

-(NSArray *)parseArray{
    NSMutableArray *array = [NSMutableArray array];
    skipWhiteSpace(_cjson, &_index);
    _index += 1;
    skipWhiteSpace(_cjson, &_index);
    if(*(_cjson + _index) == ']'){
        _index += 1;
        return array;
    }
    while (true) {
        id value = [self parse];
        if(value == nil){
            return  nil;
        }
        [array addObject:value];
        skipWhiteSpace(_cjson, &_index);
        if(*(_cjson + _index) == ']'){
            break;
        }
        if(*(_cjson + _index) != ','){
            @throw [NSException exceptionWithName:@"JSONSerializationException" reason:@"JSON解析Array出错" userInfo:nil];
        }
        _index += 1;
        skipWhiteSpace(_cjson, &_index);
    }
    _index += 1;
    return array;
}
@end
