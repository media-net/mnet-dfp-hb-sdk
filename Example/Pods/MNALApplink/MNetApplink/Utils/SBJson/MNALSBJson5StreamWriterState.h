/*
 Copyright (c) 2010, Stig Brautaset.
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

 Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.

 Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.

 Neither the name of the the author nor the names of its contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

@class MNALSBJson5StreamWriter;

@interface MNALSBJson5StreamWriterState : NSObject
+ (id)sharedInstance;
- (BOOL)isInvalidState:(MNALSBJson5StreamWriter *)writer;
- (void)appendSeparator:(MNALSBJson5StreamWriter *)writer;
- (BOOL)expectingKey:(MNALSBJson5StreamWriter *)writer;
- (void)transitionState:(MNALSBJson5StreamWriter *)writer;
- (void)appendWhitespace:(MNALSBJson5StreamWriter *)writer;
@end

@interface MNALSBJson5StreamWriterStateObjectStart : MNALSBJson5StreamWriterState
@end

@interface MNALSBJson5StreamWriterStateObjectKey : MNALSBJson5StreamWriterStateObjectStart
@end

@interface MNALSBJson5StreamWriterStateObjectValue : MNALSBJson5StreamWriterState
@end

@interface MNALSBJson5StreamWriterStateArrayStart : MNALSBJson5StreamWriterState
@end

@interface MNALSBJson5StreamWriterStateArrayValue : MNALSBJson5StreamWriterState
@end

@interface MNALSBJson5StreamWriterStateStart : MNALSBJson5StreamWriterState
@end

@interface MNALSBJson5StreamWriterStateComplete : MNALSBJson5StreamWriterState
@end

@interface MNALSBJson5StreamWriterStateError : MNALSBJson5StreamWriterState
@end
