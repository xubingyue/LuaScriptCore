//
//  LuaObjectEncoder.hpp
//  LuaScriptCore
//
//  Created by 冯鸿杰 on 16/11/15.
//  Copyright © 2016年 冯鸿杰. All rights reserved.
//

#ifndef LuaObjectEncoder_hpp
#define LuaObjectEncoder_hpp

#include <stdio.h>
#include <string>
#include "LuaObject.h"

namespace cn
{
    namespace vimfung
    {
        namespace luascriptcore
        {
            
            /**
             对象编码器
             */
            class LuaObjectEncoder : public LuaObject
            {
            private:
                
                /**
                 数据缓冲区
                 */
                void *_buf;
                
                /**
                 缓冲区大小
                 */
                int _bufLength;
                
            private:
                
                /**
                 重新分配缓冲区

                 @param size 新增大小
                 */
                void reallocBuffer(int size);
                
            public:
                
                /**
                 创建对象编码器
                 */
                LuaObjectEncoder ();
                
                /**
                 析构对象编码器
                 */
                virtual ~LuaObjectEncoder();
                
            public:
                
                /**
                 写入一个字符

                 @param value 字符值
                 */
                void writeByte(char value);
                
                /**
                 写入一个16位整型

                 @param value 16位整型值
                 */
                void writeInt16(short value);
                
                /**
                 写入一个32位整型

                 @param value 32位整型值
                 */
                void writeInt32(int value);
                
                /**
                 写入一个64位整型

                 @param value 64位整型值
                 */
                void writeInt64(long long value);
                
                /**
                 写入一个双精度浮点型

                 @param value 双精度浮点型值
                 */
                void writeDouble(double value);
                
                /**
                 写入一个字符串

                 @param value 字符串
                 */
                void writeString(const std::string &value);
                
                /**
                 写入缓存数据

                 @param bytes 缓存数据
                 @param length 缓存大小
                 */
                void writeBuffer(const void *bytes, int length);
                
                /**
                 写入一个对象

                 @param object 对象
                 */
                void writeObject(LuaObject *object);
                
            public:
                
                /**
                 获取缓冲区数据
                 
                 @return 缓存区数据引用
                 */
                const void* getBuffer();
                
                
                /**
                 克隆缓冲区数据
                 
                 @return 缓冲区数据引用
                 */
                const void* cloneBuffer();
                
                /**
                 获取缓冲区大小

                 @return 大小
                 */
                int getBufferLength();
                
            public:
                
                /**
                 编码对象

                 @param object 对象
                 @param bytes  输出的对象编码数据
                 @return 返回编码后的数据长度
                 */
                static int encodeObject(LuaObject *object, const void** bytes);
            };
        }
    }
}



#endif /* LuaObjectEncoder_hpp */
