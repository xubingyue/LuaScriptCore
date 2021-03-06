//
//  LSCFunction.m
//  LuaScriptCore
//
//  Created by 冯鸿杰 on 16/10/27.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import "LSCFunction.h"
#import "LSCFunction_Private.h"
#import "LSCContext_Private.h"
#import "LSCValue_Private.h"

/**
 方法表名称
 */
static NSString *const FunctionsTableName = @"_tmpFuncs_";

@implementation LSCFunction

- (instancetype)initWithContext:(LSCContext *)context index:(NSInteger)index
{
    if (self = [super init])
    {
        self.context = context;
        
        lua_State *state = context.state;
        if (index < 0)
        {
            index = lua_gettop(state) + index + 1;
        }
        
        //为了达到原生层中可保留传入的function，一旦有function传入，将其放入lua的全局变量_G的_tmpFuncs_表中，
        
        lua_getglobal(state, "_G");
        if (lua_istable(state, -1))
        {
            lua_getfield(state, -1, FunctionsTableName.UTF8String);
            if (lua_isnil(state, -1))
            {
                lua_pop(state, 1);
                
                //创建引用表
                lua_newtable(state);
                
                //放入全局变量_G中
                lua_pushvalue(state, -1);
                lua_setfield(state, -3, FunctionsTableName.UTF8String);
            }
            
            self.index = [NSUUID UUID].UUIDString;
            
            lua_pushvalue(state, (int)index);
            lua_setfield(state, -2, self.index.UTF8String);
            
            //弹出_tmpFuncs_
            lua_pop(state, 1);
        }
        
        //弹出_G
        lua_pop(state, 1);
    }
    
    return self;
}

- (void)dealloc
{
    if (self.index)
    {
        //移除索引中的方法
        lua_State *state = self.context.state;
        
        lua_getglobal(state, "_G");
        if (lua_istable(state, -1))
        {
            lua_getfield(state, -1, FunctionsTableName.UTF8String);
            if (lua_istable(state, -1))
            {
                lua_pushnil(state);
                lua_setfield(state, -2, self.index.UTF8String);
            }
            
            lua_pop(state, 1);
        }
        lua_pop(state, 1);
    }
}

- (LSCValue *)invokeWithArguments:(NSArray<LSCValue *> *)arguments
{
    __weak LSCFunction *theFunc = self;
    lua_State *state = self.context.state;
    
    LSCValue *retValue = nil;
    
    lua_getglobal(state, "_G");
    if (lua_istable(state, -1))
    {
        lua_getfield(state, -1, FunctionsTableName.UTF8String);
        if (lua_istable(state, -1))
        {
            lua_getfield(state, -1, self.index.UTF8String);
            if (lua_isfunction(state, -1))
            {
                [arguments enumerateObjectsUsingBlock:^(LSCValue *_Nonnull value, NSUInteger idx, BOOL *_Nonnull stop) {
                    
                    [value pushWithContext:theFunc.context];
                    
                }];
                
                if (lua_pcall(state, (int)arguments.count, 1, 0) == 0)
                {
                    retValue = [LSCValue valueWithContext:self.context atIndex:-1];
                }
                else
                {
                    //调用失败
                    LSCValue *value = [LSCValue valueWithContext:self.context atIndex:-1];
                    NSString *errMessage = [value toString];
                    [self.context raiseExceptionWithMessage:errMessage];
                }
            }
            
            //弹出返回值
            lua_pop(state, 1);
            
        }
        
        //弹出_tmpFuncs_
        lua_pop(state, 1);
        
    }
    
    //弹出_G
    lua_pop(state, 1);
    
    if (!retValue)
    {
        retValue = [LSCValue nilValue];
    }
    
    //释放内存
    lua_gc(state, LUA_GCCOLLECT, 0);
    
    return retValue;
}

- (void)push
{
    lua_State *state = self.context.state;
    
    lua_getglobal(state, "_G");
    if (lua_istable(state, -1))
    {
        lua_getfield(state, -1, FunctionsTableName.UTF8String);
        if (lua_istable(state, -1))
        {
            lua_getfield(state, -1, self.index.UTF8String);
        }
        else
        {
            lua_pushnil(state);
        }
        lua_remove(state, -2);
        
    }
    else
    {
        lua_pushnil(state);
    }
    lua_remove(state, -2);
}

@end
