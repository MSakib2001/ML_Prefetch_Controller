	.file	"daxpy.cpp"
# GNU C++20 (Ubuntu 13.3.0-6ubuntu2~24.04) version 13.3.0 (x86_64-linux-gnu)
#	compiled by GNU C version 13.3.0, GMP version 6.3.0, MPFR version 4.2.1, MPC version 1.3.1, isl version isl-0.26-GMP

# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed: -mtune=generic -march=x86-64 -O3 -std=gnu++20 -fasynchronous-unwind-tables -fstack-protector-strong -fstack-clash-protection -fcf-protection
	.text
	.section	.text._ZNSt13random_deviceC2Ev,"axG",@progbits,_ZNSt13random_deviceC5Ev,comdat
	.align 2
	.p2align 4
	.weak	_ZNSt13random_deviceC2Ev
	.type	_ZNSt13random_deviceC2Ev, @function
_ZNSt13random_deviceC2Ev:
.LFB2892:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA2892
	endbr64	
	pushq	%rbp	#
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	pushq	%rbx	#
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	subq	$56, %rsp	#,
	.cfi_def_cfa_offset 80
# /usr/include/c++/13/bits/random.h:1658:     random_device() { _M_init("default"); }
	movq	%fs:40, %rax	# MEM[(<address-space-1> long unsigned int *)40B], tmp110
	movq	%rax, 40(%rsp)	# tmp110, D.84257
	xorl	%eax, %eax	# tmp110
# /usr/include/c++/13/bits/basic_string.h:189: 	: allocator_type(__a), _M_p(__dat) { }
	leaq	16(%rsp), %rbx	#, tmp107
	movq	%rsp, %rsi	#, tmp91
# /usr/include/c++/13/bits/char_traits.h:358: 	__c1 = __c2;
	movb	$0, 23(%rsp)	#, MEM[(char_type &)&D.64683 + 23]
# /usr/include/c++/13/bits/char_traits.h:435: 	return static_cast<char_type*>(__builtin_memcpy(__s1, __s2, __n));
	movl	$1634100580, 16(%rsp)	#, MEM <char[1:7]> [(void *)&D.64683 + 16B]
# /usr/include/c++/13/bits/basic_string.h:189: 	: allocator_type(__a), _M_p(__dat) { }
	movq	%rbx, (%rsp)	# tmp107, MEM[(struct _Alloc_hider *)&D.64683]._M_p
# /usr/include/c++/13/bits/char_traits.h:435: 	return static_cast<char_type*>(__builtin_memcpy(__s1, __s2, __n));
	movl	$1953264993, 19(%rsp)	#, MEM <char[1:7]> [(void *)&D.64683 + 16B]
# /usr/include/c++/13/bits/basic_string.h:218:       { _M_string_length = __length; }
	movq	$7, 8(%rsp)	#, D.64683._M_string_length
.LEHB0:
# /usr/include/c++/13/bits/random.h:1658:     random_device() { _M_init("default"); }
	call	_ZNSt13random_device7_M_initERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE@PLT	#
.LEHE0:
# /usr/include/c++/13/bits/basic_string.h:223:       { return _M_dataplus._M_p; }
	movq	(%rsp), %rdi	# D.64683._M_dataplus._M_p, _36
# /usr/include/c++/13/bits/basic_string.h:264: 	if (_M_data() == _M_local_data())
	cmpq	%rbx, %rdi	# tmp107, _36
	je	.L1	#,
# /usr/include/c++/13/bits/basic_string.h:289:       { _Alloc_traits::deallocate(_M_get_allocator(), _M_data(), __size + 1); }
	movq	16(%rsp), %rax	# D.64683.D.44564._M_allocated_capacity, tmp114
	leaq	1(%rax), %rsi	#, tmp98
# /usr/include/c++/13/bits/new_allocator.h:172: 	_GLIBCXX_OPERATOR_DELETE(_GLIBCXX_SIZED_DEALLOC(__p, __n));
	call	_ZdlPvm@PLT	#
.L1:
# /usr/include/c++/13/bits/random.h:1658:     random_device() { _M_init("default"); }
	movq	40(%rsp), %rax	# D.84257, tmp112
	subq	%fs:40, %rax	# MEM[(<address-space-1> long unsigned int *)40B], tmp112
	jne	.L9	#,
	addq	$56, %rsp	#,
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbx	#
	.cfi_def_cfa_offset 16
	popq	%rbp	#
	.cfi_def_cfa_offset 8
	ret	
.L3:
	.cfi_restore_state
# /usr/include/c++/13/bits/basic_string.h:223:       { return _M_dataplus._M_p; }
	movq	(%rsp), %rdi	# D.64683._M_dataplus._M_p, _42
# /usr/include/c++/13/bits/basic_string.h:264: 	if (_M_data() == _M_local_data())
	cmpq	%rbx, %rdi	# tmp107, _42
	jne	.L11	#,
.L4:
	movq	40(%rsp), %rax	# D.84257, tmp111
	subq	%fs:40, %rax	# MEM[(<address-space-1> long unsigned int *)40B], tmp111
	je	.L5	#,
.L9:
# /usr/include/c++/13/bits/random.h:1658:     random_device() { _M_init("default"); }
	call	__stack_chk_fail@PLT	#
.L7:
	endbr64	
# /usr/include/c++/13/bits/basic_string.h:223:       { return _M_dataplus._M_p; }
	movq	%rax, %rbp	# tmp109, tmp104
	jmp	.L3	#
.L11:
# /usr/include/c++/13/bits/basic_string.h:289:       { _Alloc_traits::deallocate(_M_get_allocator(), _M_data(), __size + 1); }
	movq	16(%rsp), %rax	# D.64683.D.44564._M_allocated_capacity, tmp115
	leaq	1(%rax), %rsi	#, tmp102
# /usr/include/c++/13/bits/new_allocator.h:172: 	_GLIBCXX_OPERATOR_DELETE(_GLIBCXX_SIZED_DEALLOC(__p, __n));
	call	_ZdlPvm@PLT	#
	jmp	.L4	#
.L5:
	movq	%rbp, %rdi	# tmp104,
.LEHB1:
	call	_Unwind_Resume@PLT	#
.LEHE1:
	.cfi_endproc
.LFE2892:
	.globl	__gxx_personality_v0
	.section	.gcc_except_table._ZNSt13random_deviceC2Ev,"aG",@progbits,_ZNSt13random_deviceC5Ev,comdat
.LLSDA2892:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE2892-.LLSDACSB2892
.LLSDACSB2892:
	.uleb128 .LEHB0-.LFB2892
	.uleb128 .LEHE0-.LEHB0
	.uleb128 .L7-.LFB2892
	.uleb128 0
	.uleb128 .LEHB1-.LFB2892
	.uleb128 .LEHE1-.LEHB1
	.uleb128 0
	.uleb128 0
.LLSDACSE2892:
	.section	.text._ZNSt13random_deviceC2Ev,"axG",@progbits,_ZNSt13random_deviceC5Ev,comdat
	.size	_ZNSt13random_deviceC2Ev, .-_ZNSt13random_deviceC2Ev
	.weak	_ZNSt13random_deviceC1Ev
	.set	_ZNSt13random_deviceC1Ev,_ZNSt13random_deviceC2Ev
	.section	.text._ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv,"axG",@progbits,_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv,comdat
	.align 2
	.p2align 4
	.weak	_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv
	.type	_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv, @function
_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv:
.LFB4297:
	.cfi_startproc
	endbr64	
	movdqa	.LC0(%rip), %xmm3	#, tmp191
# /usr/include/c++/13/bits/random.tcc:397:     mersenne_twister_engine<_UIntType, __w, __n, __m, __r, __a, __u, __d,
	movq	%rdi, %rcx	# tmp195, this
	movq	%rdi, %rax	# this, ivtmp.155
	movdqa	.LC1(%rip), %xmm4	#, tmp192
	movdqa	.LC2(%rip), %xmm5	#, tmp193
	movdqa	.LC3(%rip), %xmm6	#, tmp194
	leaq	1808(%rdi), %rdx	#, _8
# /usr/include/c++/13/bits/random.tcc:408: 	  _M_x[__k] = (_M_x[__k + __m] ^ (__y >> 1)
	pxor	%xmm7, %xmm7	# tmp151
	.p2align 4,,10
	.p2align 3
.L13:
# /usr/include/c++/13/bits/random.tcc:406: 	  _UIntType __y = ((_M_x[__k] & __upper_mask)
	movdqu	(%rax), %xmm0	# MEM <vector(2) long unsigned int> [(long unsigned int *)_4], vect__2.122
# /usr/include/c++/13/bits/random.tcc:407: 			   | (_M_x[__k + 1] & __lower_mask));
	movdqu	8(%rax), %xmm1	# MEM <vector(2) long unsigned int> [(long unsigned int *)_4 + 8B], vect__5.126
	addq	$16, %rax	#, ivtmp.155
# /usr/include/c++/13/bits/random.tcc:408: 	  _M_x[__k] = (_M_x[__k + __m] ^ (__y >> 1)
	movdqu	3160(%rax), %xmm2	# MEM <vector(2) long unsigned int> [(long unsigned int *)_4 + 3176B], tmp200
# /usr/include/c++/13/bits/random.tcc:407: 			   | (_M_x[__k + 1] & __lower_mask));
	pand	%xmm4, %xmm1	# tmp192, vect__5.126
# /usr/include/c++/13/bits/random.tcc:406: 	  _UIntType __y = ((_M_x[__k] & __upper_mask)
	pand	%xmm3, %xmm0	# tmp191, vect__2.122
# /usr/include/c++/13/bits/random.tcc:406: 	  _UIntType __y = ((_M_x[__k] & __upper_mask)
	por	%xmm1, %xmm0	# vect__5.126, vect___y_46.127
# /usr/include/c++/13/bits/random.tcc:408: 	  _M_x[__k] = (_M_x[__k + __m] ^ (__y >> 1)
	movdqa	%xmm0, %xmm1	# vect___y_46.127, vect__8.131
# /usr/include/c++/13/bits/random.tcc:409: 		       ^ ((__y & 0x01) ? __a : 0));
	pand	%xmm5, %xmm0	# tmp193, vect__10.133
# /usr/include/c++/13/bits/random.tcc:408: 	  _M_x[__k] = (_M_x[__k + __m] ^ (__y >> 1)
	psrlq	$1, %xmm1	#, vect__8.131
# /usr/include/c++/13/bits/random.tcc:408: 	  _M_x[__k] = (_M_x[__k + __m] ^ (__y >> 1)
	pxor	%xmm2, %xmm1	# tmp200, vect__9.132
# /usr/include/c++/13/bits/random.tcc:408: 	  _M_x[__k] = (_M_x[__k + __m] ^ (__y >> 1)
	movdqa	%xmm7, %xmm2	# tmp151, vect__98.134
	psubq	%xmm0, %xmm2	# vect__10.133, vect__98.134
	pand	%xmm6, %xmm2	# tmp194, vect__98.134
	movdqa	%xmm2, %xmm0	# vect__98.134, vect__99.135
	pxor	%xmm1, %xmm0	# vect__9.132, vect_prephitmp_86.136
	movups	%xmm0, -16(%rax)	# vect_prephitmp_86.136, MEM <vector(2) long unsigned int> [(long unsigned int *)_4]
	cmpq	%rdx, %rax	# _8, ivtmp.155
	jne	.L13	#,
# /usr/include/c++/13/bits/random.tcc:406: 	  _UIntType __y = ((_M_x[__k] & __upper_mask)
	movq	1808(%rcx), %rdx	# this_40(D)->_M_x[226], tmp155
# /usr/include/c++/13/bits/random.tcc:407: 			   | (_M_x[__k + 1] & __lower_mask));
	movq	1816(%rcx), %rax	# this_40(D)->_M_x[227], tmp157
# /usr/include/c++/13/bits/random.tcc:416: 	  _M_x[__k] = (_M_x[__k + (__m - __n)] ^ (__y >> 1)
	pxor	%xmm7, %xmm7	# tmp177
# /usr/include/c++/13/bits/random.tcc:407: 			   | (_M_x[__k + 1] & __lower_mask));
	andl	$2147483647, %eax	#, tmp157
# /usr/include/c++/13/bits/random.tcc:406: 	  _UIntType __y = ((_M_x[__k] & __upper_mask)
	andq	$-2147483648, %rdx	#, tmp155
# /usr/include/c++/13/bits/random.tcc:406: 	  _UIntType __y = ((_M_x[__k] & __upper_mask)
	orq	%rax, %rdx	# tmp157, __y
# /usr/include/c++/13/bits/random.tcc:409: 		       ^ ((__y & 0x01) ? __a : 0));
	andl	$1, %eax	#, tmp159
# /usr/include/c++/13/bits/random.tcc:409: 		       ^ ((__y & 0x01) ? __a : 0));
	negq	%rax	# tmp160
# /usr/include/c++/13/bits/random.tcc:408: 	  _M_x[__k] = (_M_x[__k + __m] ^ (__y >> 1)
	shrq	%rdx	# tmp162
# /usr/include/c++/13/bits/random.tcc:408: 	  _M_x[__k] = (_M_x[__k + __m] ^ (__y >> 1)
	xorq	4984(%rcx), %rdx	# this_40(D)->_M_x[623], tmp163
# /usr/include/c++/13/bits/random.tcc:409: 		       ^ ((__y & 0x01) ? __a : 0));
	andl	$2567483615, %eax	#, tmp161
	xorq	%rdx, %rax	# tmp163, tmp164
	leaq	4984(%rcx), %rdx	#, _52
	movq	%rax, 1808(%rcx)	# tmp164, this_40(D)->_M_x[226]
	leaq	1816(%rcx), %rax	#, ivtmp.146
.L14:
# /usr/include/c++/13/bits/random.tcc:414: 	  _UIntType __y = ((_M_x[__k] & __upper_mask)
	movdqu	(%rax), %xmm0	# MEM <vector(2) long unsigned int> [(long unsigned int *)_128], vect__13.100
# /usr/include/c++/13/bits/random.tcc:415: 			   | (_M_x[__k + 1] & __lower_mask));
	movdqu	8(%rax), %xmm1	# MEM <vector(2) long unsigned int> [(long unsigned int *)_128 + 8B], vect__16.104
	addq	$16, %rax	#, ivtmp.146
# /usr/include/c++/13/bits/random.tcc:416: 	  _M_x[__k] = (_M_x[__k + (__m - __n)] ^ (__y >> 1)
	movdqu	-1832(%rax), %xmm2	# MEM <vector(2) long unsigned int> [(long unsigned int *)_128 + -1816B], tmp208
# /usr/include/c++/13/bits/random.tcc:415: 			   | (_M_x[__k + 1] & __lower_mask));
	pand	%xmm4, %xmm1	# tmp192, vect__16.104
# /usr/include/c++/13/bits/random.tcc:414: 	  _UIntType __y = ((_M_x[__k] & __upper_mask)
	pand	%xmm3, %xmm0	# tmp191, vect__13.100
# /usr/include/c++/13/bits/random.tcc:414: 	  _UIntType __y = ((_M_x[__k] & __upper_mask)
	por	%xmm1, %xmm0	# vect__16.104, vect___y_44.105
# /usr/include/c++/13/bits/random.tcc:416: 	  _M_x[__k] = (_M_x[__k + (__m - __n)] ^ (__y >> 1)
	movdqa	%xmm0, %xmm1	# vect___y_44.105, vect__19.109
# /usr/include/c++/13/bits/random.tcc:417: 		       ^ ((__y & 0x01) ? __a : 0));
	pand	%xmm5, %xmm0	# tmp193, vect__21.111
# /usr/include/c++/13/bits/random.tcc:416: 	  _M_x[__k] = (_M_x[__k + (__m - __n)] ^ (__y >> 1)
	psrlq	$1, %xmm1	#, vect__19.109
# /usr/include/c++/13/bits/random.tcc:416: 	  _M_x[__k] = (_M_x[__k + (__m - __n)] ^ (__y >> 1)
	pxor	%xmm2, %xmm1	# tmp208, vect__20.110
# /usr/include/c++/13/bits/random.tcc:416: 	  _M_x[__k] = (_M_x[__k + (__m - __n)] ^ (__y >> 1)
	movdqa	%xmm7, %xmm2	# tmp177, vect__61.112
	psubq	%xmm0, %xmm2	# vect__21.111, vect__61.112
	pand	%xmm6, %xmm2	# tmp194, vect__61.112
	movdqa	%xmm2, %xmm0	# vect__61.112, vect__60.113
	pxor	%xmm1, %xmm0	# vect__20.110, vect_prephitmp_89.114
	movups	%xmm0, -16(%rax)	# vect_prephitmp_89.114, MEM <vector(2) long unsigned int> [(long unsigned int *)_128]
	cmpq	%rax, %rdx	# ivtmp.146, _52
	jne	.L14	#,
# /usr/include/c++/13/bits/random.tcc:420:       _UIntType __y = ((_M_x[__n - 1] & __upper_mask)
	movq	4984(%rcx), %rax	# this_40(D)->_M_x[623], tmp181
# /usr/include/c++/13/bits/random.tcc:421: 		       | (_M_x[0] & __lower_mask));
	movq	(%rcx), %rdx	# this_40(D)->_M_x[0], tmp183
# /usr/include/c++/13/bits/random.tcc:424:       _M_p = 0;
	movq	$0, 4992(%rcx)	#, this_40(D)->_M_p
# /usr/include/c++/13/bits/random.tcc:421: 		       | (_M_x[0] & __lower_mask));
	andl	$2147483647, %edx	#, tmp183
# /usr/include/c++/13/bits/random.tcc:420:       _UIntType __y = ((_M_x[__n - 1] & __upper_mask)
	andq	$-2147483648, %rax	#, tmp181
# /usr/include/c++/13/bits/random.tcc:420:       _UIntType __y = ((_M_x[__n - 1] & __upper_mask)
	orq	%rdx, %rax	# tmp183, __y
# /usr/include/c++/13/bits/random.tcc:422:       _M_x[__n - 1] = (_M_x[__m - 1] ^ (__y >> 1)
	movq	%rax, %rdx	# __y, tmp185
# /usr/include/c++/13/bits/random.tcc:423: 		       ^ ((__y & 0x01) ? __a : 0));
	andl	$1, %eax	#, tmp187
# /usr/include/c++/13/bits/random.tcc:423: 		       ^ ((__y & 0x01) ? __a : 0));
	negq	%rax	# tmp188
# /usr/include/c++/13/bits/random.tcc:422:       _M_x[__n - 1] = (_M_x[__m - 1] ^ (__y >> 1)
	shrq	%rdx	# tmp185
# /usr/include/c++/13/bits/random.tcc:422:       _M_x[__n - 1] = (_M_x[__m - 1] ^ (__y >> 1)
	xorq	3168(%rcx), %rdx	# this_40(D)->_M_x[396], tmp186
# /usr/include/c++/13/bits/random.tcc:423: 		       ^ ((__y & 0x01) ? __a : 0));
	andl	$2567483615, %eax	#, tmp189
	xorq	%rdx, %rax	# tmp186, tmp190
	movq	%rax, 4984(%rcx)	# tmp190, this_40(D)->_M_x[623]
# /usr/include/c++/13/bits/random.tcc:425:     }
	ret	
	.cfi_endproc
.LFE4297:
	.size	_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv, .-_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC11:
	.string	"%lf\n"
	.section	.text.unlikely,"ax",@progbits
.LCOLDB12:
	.section	.text.startup,"ax",@progbits
.LHOTB12:
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB3474:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA3474
	endbr64	
	pushq	%r14	#
	.cfi_def_cfa_offset 16
	.cfi_offset 14, -16
	pushq	%r13	#
	.cfi_def_cfa_offset 24
	.cfi_offset 13, -24
	pushq	%r12	#
	.cfi_def_cfa_offset 32
	.cfi_offset 12, -32
	pushq	%rbp	#
	.cfi_def_cfa_offset 40
	.cfi_offset 6, -40
	pushq	%rbx	#
	.cfi_def_cfa_offset 48
	.cfi_offset 3, -48
	leaq	-73728(%rsp), %r11	#,
	.cfi_def_cfa 11, 73776
.LPSRL0:
	subq	$4096, %rsp	#,
	orq	$0, (%rsp)	#,
	cmpq	%r11, %rsp	#,
	jne	.LPSRL0
	.cfi_def_cfa_register 7
	subq	$1856, %rsp	#,
	.cfi_def_cfa_offset 75632
# daxpy.cpp:17: {
	movq	%fs:40, %rax	# MEM[(<address-space-1> long unsigned int *)40B], tmp258
	movq	%rax, 75576(%rsp)	# tmp258, D.84413
	xorl	%eax, %eax	# tmp258
# daxpy.cpp:20:   std::random_device rd; std::mt19937 gen(rd());
	leaq	16(%rsp), %r13	#, tmp253
	movq	%r13, %rdi	# tmp253,
.LEHB2:
	call	_ZNSt13random_deviceC1Ev	#
.LEHE2:
# /usr/include/c++/13/bits/random.h:1680:     { return this->_M_getval(); }
	movq	%r13, %rdi	# tmp253,
.LEHB3:
	call	_ZNSt13random_device9_M_getvalEv@PLT	#
# daxpy.cpp:20:   std::random_device rd; std::mt19937 gen(rd());
	movl	%eax, %ecx	# tmp256, gen___M_x_I_lsm0.187
# /usr/include/c++/13/bits/random.tcc:333:       for (size_t __i = 1; __i < state_size; ++__i)
	movl	$1, %edx	#, __i
	leaq	5024(%rsp), %r12	#, tmp247
# /usr/include/c++/13/bits/random.tcc:330:       _M_x[0] = __detail::__mod<_UIntType,
	movq	%rcx, 5024(%rsp)	# gen___M_x_I_lsm0.187, MEM[(struct mersenne_twister_engine *)&gen]._M_x[0]
	.p2align 4,,10
	.p2align 3
.L18:
# /usr/include/c++/13/bits/random.tcc:336: 	  __x ^= __x >> (__w - 2);
	movq	%rcx, %rax	# gen___M_x_I_lsm0.187, tmp177
	shrq	$30, %rax	#, tmp177
# /usr/include/c++/13/bits/random.tcc:336: 	  __x ^= __x >> (__w - 2);
	xorq	%rcx, %rax	# gen___M_x_I_lsm0.187, __x
# /usr/include/c++/13/bits/random.tcc:337: 	  __x *= __f;
	imulq	$1812433253, %rax, %rax	#, __x, __x
# /usr/include/c++/13/bits/random.h:143: 	    __res %= __m;
	leal	(%rax,%rdx), %ecx	#, gen___M_x_I_lsm0.187
# /usr/include/c++/13/bits/random.tcc:339: 	  _M_x[__i] = __detail::__mod<_UIntType,
	movq	%rcx, (%r12,%rdx,8)	# gen___M_x_I_lsm0.187, MEM[(long unsigned int *)&gen + __i_109 * 8]
# /usr/include/c++/13/bits/random.tcc:333:       for (size_t __i = 1; __i < state_size; ++__i)
	addq	$1, %rdx	#, __i
# /usr/include/c++/13/bits/random.tcc:333:       for (size_t __i = 1; __i < state_size; ++__i)
	cmpq	$624, %rdx	#, __i
	jne	.L18	#,
# /usr/include/c++/13/bits/random.tcc:342:       _M_p = state_size;
	movq	$624, 10016(%rsp)	#, MEM[(struct mersenne_twister_engine *)&gen]._M_p
	movsd	.LC8(%rip), %xmm2	#, tmp250
	xorl	%r14d, %r14d	# ivtmp.210
	leaq	10032(%rsp), %rbp	#, ivtmp.201
	leaq	42800(%rsp), %rbx	#, ivtmp.193
	jmp	.L19	#
	.p2align 4,,10
	.p2align 3
.L55:
# /usr/include/c++/13/bits/random.tcc:3367: 	  __sum += _RealType(__urng() - __urng.min()) * __tmp;
	pxor	%xmm1, %xmm1	# tmp215
	cvtsi2sdq	%rax, %xmm1	# __z, tmp215
.L31:
# /usr/include/c++/13/bits/random.tcc:3367: 	  __sum += _RealType(__urng() - __urng.min()) * __tmp;
	pxor	%xmm4, %xmm4	# tmp280
	addsd	%xmm4, %xmm1	# tmp280, __sum
# /usr/include/c++/13/bits/random.tcc:458:       if (_M_p >= state_size)
	cmpq	$623, %rcx	#, _186
	ja	.L51	#,
.L32:
# /usr/include/c++/13/bits/random.tcc:462:       result_type __z = _M_x[_M_p++];
	movq	5024(%rsp,%rcx,8), %rax	# gen._M_x[prephitmp_299], __z
# /usr/include/c++/13/bits/random.tcc:462:       result_type __z = _M_x[_M_p++];
	leaq	1(%rcx), %rdx	#, _215
	movq	%rdx, 10016(%rsp)	# _215, gen._M_p
# /usr/include/c++/13/bits/random.tcc:463:       __z ^= (__z >> __u) & __d;
	movq	%rax, %rcx	# __z, tmp221
	shrq	$11, %rcx	#, tmp221
# /usr/include/c++/13/bits/random.tcc:463:       __z ^= (__z >> __u) & __d;
	movl	%ecx, %ecx	# tmp221, _219
# /usr/include/c++/13/bits/random.tcc:463:       __z ^= (__z >> __u) & __d;
	xorq	%rcx, %rax	# _219, __z
# /usr/include/c++/13/bits/random.tcc:464:       __z ^= (__z << __s) & __b;
	movq	%rax, %rcx	# __z, tmp222
	salq	$7, %rcx	#, tmp222
# /usr/include/c++/13/bits/random.tcc:464:       __z ^= (__z << __s) & __b;
	andl	$2636928640, %ecx	#, _222
# /usr/include/c++/13/bits/random.tcc:464:       __z ^= (__z << __s) & __b;
	xorq	%rcx, %rax	# _222, __z
# /usr/include/c++/13/bits/random.tcc:465:       __z ^= (__z << __t) & __c;
	movq	%rax, %rcx	# __z, tmp223
	salq	$15, %rcx	#, tmp223
# /usr/include/c++/13/bits/random.tcc:465:       __z ^= (__z << __t) & __c;
	andl	$4022730752, %ecx	#, _225
# /usr/include/c++/13/bits/random.tcc:465:       __z ^= (__z << __t) & __c;
	xorq	%rcx, %rax	# _225, __z
# /usr/include/c++/13/bits/random.tcc:466:       __z ^= (__z >> __l);
	movq	%rax, %rcx	# __z, _227
	shrq	$18, %rcx	#, _227
# /usr/include/c++/13/bits/random.tcc:3367: 	  __sum += _RealType(__urng() - __urng.min()) * __tmp;
	xorq	%rcx, %rax	# _227, __z
	js	.L33	#,
	pxor	%xmm0, %xmm0	# tmp225
	cvtsi2sdq	%rax, %xmm0	# __z, tmp225
.L34:
# /usr/include/c++/13/bits/random.tcc:3367: 	  __sum += _RealType(__urng() - __urng.min()) * __tmp;
	mulsd	.LC6(%rip), %xmm0	#, tmp229
# /usr/include/c++/13/bits/random.tcc:3367: 	  __sum += _RealType(__urng() - __urng.min()) * __tmp;
	addsd	%xmm1, %xmm0	# __sum, __sum
# /usr/include/c++/13/bits/random.tcc:3370:       __ret = __sum / __tmp;
	mulsd	.LC7(%rip), %xmm0	#, __ret
# /usr/include/c++/13/bits/random.tcc:3371:       if (__builtin_expect(__ret >= _RealType(1), 0))
	comisd	%xmm2, %xmm0	# tmp250, __ret
	jnb	.L41	#,
# /usr/include/c++/13/bits/random.h:1909: 	  return (__aurng() * (__p.b() - __p.a())) + __p.a();
	addsd	%xmm2, %xmm0	# tmp250, _301
.L35:
# daxpy.cpp:24: 	X[i] = dis(gen);
	movsd	%xmm0, (%r14,%rbp)	# _301, MEM[(double *)&X + ivtmp.210_261 * 1]
# /usr/include/c++/13/bits/random.tcc:458:       if (_M_p >= state_size)
	cmpq	$623, %rdx	#, _215
	ja	.L52	#,
.L20:
# /usr/include/c++/13/bits/random.tcc:462:       result_type __z = _M_x[_M_p++];
	movq	5024(%rsp,%rdx,8), %rax	# gen._M_x[prephitmp_304], __z
# /usr/include/c++/13/bits/random.tcc:462:       result_type __z = _M_x[_M_p++];
	leaq	1(%rdx), %rcx	#, _39
	movq	%rcx, 10016(%rsp)	# _39, gen._M_p
# /usr/include/c++/13/bits/random.tcc:463:       __z ^= (__z >> __u) & __d;
	movq	%rax, %rdx	# __z, tmp182
	shrq	$11, %rdx	#, tmp182
# /usr/include/c++/13/bits/random.tcc:463:       __z ^= (__z >> __u) & __d;
	movl	%edx, %edx	# tmp182, _75
# /usr/include/c++/13/bits/random.tcc:463:       __z ^= (__z >> __u) & __d;
	xorq	%rdx, %rax	# _75, __z
# /usr/include/c++/13/bits/random.tcc:464:       __z ^= (__z << __s) & __b;
	movq	%rax, %rdx	# __z, tmp183
	salq	$7, %rdx	#, tmp183
# /usr/include/c++/13/bits/random.tcc:464:       __z ^= (__z << __s) & __b;
	andl	$2636928640, %edx	#, _135
# /usr/include/c++/13/bits/random.tcc:464:       __z ^= (__z << __s) & __b;
	xorq	%rdx, %rax	# _135, __z
# /usr/include/c++/13/bits/random.tcc:465:       __z ^= (__z << __t) & __c;
	movq	%rax, %rdx	# __z, tmp184
	salq	$15, %rdx	#, tmp184
# /usr/include/c++/13/bits/random.tcc:465:       __z ^= (__z << __t) & __c;
	andl	$4022730752, %edx	#, _138
# /usr/include/c++/13/bits/random.tcc:465:       __z ^= (__z << __t) & __c;
	xorq	%rdx, %rax	# _138, __z
# /usr/include/c++/13/bits/random.tcc:466:       __z ^= (__z >> __l);
	movq	%rax, %rdx	# __z, _140
	shrq	$18, %rdx	#, _140
# /usr/include/c++/13/bits/random.tcc:3367: 	  __sum += _RealType(__urng() - __urng.min()) * __tmp;
	xorq	%rdx, %rax	# _140, __z
	js	.L21	#,
	pxor	%xmm1, %xmm1	# tmp186
	cvtsi2sdq	%rax, %xmm1	# __z, tmp186
.L22:
# /usr/include/c++/13/bits/random.tcc:3367: 	  __sum += _RealType(__urng() - __urng.min()) * __tmp;
	pxor	%xmm3, %xmm3	# tmp268
	addsd	%xmm3, %xmm1	# tmp268, __sum
# /usr/include/c++/13/bits/random.tcc:458:       if (_M_p >= state_size)
	cmpq	$623, %rcx	#, _39
	ja	.L53	#,
.L23:
# /usr/include/c++/13/bits/random.tcc:462:       result_type __z = _M_x[_M_p++];
	movq	5024(%rsp,%rcx,8), %rax	# gen._M_x[prephitmp_307], __z
# /usr/include/c++/13/bits/random.tcc:462:       result_type __z = _M_x[_M_p++];
	leaq	1(%rcx), %rdx	#, __i
	movq	%rdx, 10016(%rsp)	# __i, gen._M_p
# /usr/include/c++/13/bits/random.tcc:463:       __z ^= (__z >> __u) & __d;
	movq	%rax, %rcx	# __z, tmp192
	shrq	$11, %rcx	#, tmp192
# /usr/include/c++/13/bits/random.tcc:463:       __z ^= (__z >> __u) & __d;
	movl	%ecx, %ecx	# tmp192, _161
# /usr/include/c++/13/bits/random.tcc:463:       __z ^= (__z >> __u) & __d;
	xorq	%rcx, %rax	# _161, __z
# /usr/include/c++/13/bits/random.tcc:464:       __z ^= (__z << __s) & __b;
	movq	%rax, %rcx	# __z, tmp193
	salq	$7, %rcx	#, tmp193
# /usr/include/c++/13/bits/random.tcc:464:       __z ^= (__z << __s) & __b;
	andl	$2636928640, %ecx	#, _164
# /usr/include/c++/13/bits/random.tcc:464:       __z ^= (__z << __s) & __b;
	xorq	%rcx, %rax	# _164, __z
# /usr/include/c++/13/bits/random.tcc:465:       __z ^= (__z << __t) & __c;
	movq	%rax, %rcx	# __z, tmp194
	salq	$15, %rcx	#, tmp194
# /usr/include/c++/13/bits/random.tcc:465:       __z ^= (__z << __t) & __c;
	andl	$4022730752, %ecx	#, _167
# /usr/include/c++/13/bits/random.tcc:465:       __z ^= (__z << __t) & __c;
	xorq	%rcx, %rax	# _167, __z
# /usr/include/c++/13/bits/random.tcc:466:       __z ^= (__z >> __l);
	movq	%rax, %rcx	# __z, _169
	shrq	$18, %rcx	#, _169
# /usr/include/c++/13/bits/random.tcc:3367: 	  __sum += _RealType(__urng() - __urng.min()) * __tmp;
	xorq	%rcx, %rax	# _169, __z
	js	.L24	#,
	pxor	%xmm0, %xmm0	# tmp196
	cvtsi2sdq	%rax, %xmm0	# __z, tmp196
.L25:
# /usr/include/c++/13/bits/random.tcc:3367: 	  __sum += _RealType(__urng() - __urng.min()) * __tmp;
	mulsd	.LC6(%rip), %xmm0	#, tmp200
# /usr/include/c++/13/bits/random.tcc:3367: 	  __sum += _RealType(__urng() - __urng.min()) * __tmp;
	addsd	%xmm1, %xmm0	# __sum, __sum
# /usr/include/c++/13/bits/random.tcc:3370:       __ret = __sum / __tmp;
	mulsd	.LC7(%rip), %xmm0	#, __ret
# /usr/include/c++/13/bits/random.tcc:3371:       if (__builtin_expect(__ret >= _RealType(1), 0))
	comisd	%xmm2, %xmm0	# tmp250, __ret
	jnb	.L26	#,
# /usr/include/c++/13/bits/random.h:1909: 	  return (__aurng() * (__p.b() - __p.a())) + __p.a();
	addsd	%xmm2, %xmm0	# tmp250, tmp206
# daxpy.cpp:22:   for (int i = 0; i < N; ++i)
	addq	$8, %r14	#, ivtmp.210
# daxpy.cpp:25: 	Y[i] = dis(gen);
	movsd	%xmm0, -8(%r14,%rbx)	# tmp206, MEM[(double *)&Y + ivtmp.210_261 * 1]
# daxpy.cpp:22:   for (int i = 0; i < N; ++i)
	cmpq	$32768, %r14	#, ivtmp.210
	je	.L28	#,
.L19:
# /usr/include/c++/13/bits/random.tcc:458:       if (_M_p >= state_size)
	cmpq	$623, %rdx	#, __i
	ja	.L54	#,
.L29:
# /usr/include/c++/13/bits/random.tcc:462:       result_type __z = _M_x[_M_p++];
	movq	5024(%rsp,%rdx,8), %rax	# gen._M_x[prephitmp_296], __z
# /usr/include/c++/13/bits/random.tcc:462:       result_type __z = _M_x[_M_p++];
	leaq	1(%rdx), %rcx	#, _186
	movq	%rcx, 10016(%rsp)	# _186, gen._M_p
# /usr/include/c++/13/bits/random.tcc:463:       __z ^= (__z >> __u) & __d;
	movq	%rax, %rdx	# __z, tmp211
	shrq	$11, %rdx	#, tmp211
# /usr/include/c++/13/bits/random.tcc:463:       __z ^= (__z >> __u) & __d;
	movl	%edx, %edx	# tmp211, _190
# /usr/include/c++/13/bits/random.tcc:463:       __z ^= (__z >> __u) & __d;
	xorq	%rdx, %rax	# _190, __z
# /usr/include/c++/13/bits/random.tcc:464:       __z ^= (__z << __s) & __b;
	movq	%rax, %rdx	# __z, tmp212
	salq	$7, %rdx	#, tmp212
# /usr/include/c++/13/bits/random.tcc:464:       __z ^= (__z << __s) & __b;
	andl	$2636928640, %edx	#, _193
# /usr/include/c++/13/bits/random.tcc:464:       __z ^= (__z << __s) & __b;
	xorq	%rdx, %rax	# _193, __z
# /usr/include/c++/13/bits/random.tcc:465:       __z ^= (__z << __t) & __c;
	movq	%rax, %rdx	# __z, tmp213
	salq	$15, %rdx	#, tmp213
# /usr/include/c++/13/bits/random.tcc:465:       __z ^= (__z << __t) & __c;
	andl	$4022730752, %edx	#, _196
# /usr/include/c++/13/bits/random.tcc:465:       __z ^= (__z << __t) & __c;
	xorq	%rdx, %rax	# _196, __z
# /usr/include/c++/13/bits/random.tcc:466:       __z ^= (__z >> __l);
	movq	%rax, %rdx	# __z, _198
	shrq	$18, %rdx	#, _198
# /usr/include/c++/13/bits/random.tcc:3367: 	  __sum += _RealType(__urng() - __urng.min()) * __tmp;
	xorq	%rdx, %rax	# _198, __z
	jns	.L55	#,
	movq	%rax, %rdx	# __z, tmp217
	andl	$1, %eax	#, tmp218
	pxor	%xmm1, %xmm1	# tmp216
	shrq	%rdx	# tmp217
	orq	%rax, %rdx	# tmp218, tmp217
	cvtsi2sdq	%rdx, %xmm1	# tmp217, tmp216
	addsd	%xmm1, %xmm1	# tmp216, tmp215
	jmp	.L31	#
	.p2align 4,,10
	.p2align 3
.L24:
	movq	%rax, %rcx	# __z, tmp198
	andl	$1, %eax	#, tmp199
	pxor	%xmm0, %xmm0	# tmp197
	shrq	%rcx	# tmp198
	orq	%rax, %rcx	# tmp199, tmp198
	cvtsi2sdq	%rcx, %xmm0	# tmp198, tmp197
	addsd	%xmm0, %xmm0	# tmp197, tmp196
	jmp	.L25	#
	.p2align 4,,10
	.p2align 3
.L21:
	movq	%rax, %rdx	# __z, tmp188
	andl	$1, %eax	#, tmp189
	pxor	%xmm1, %xmm1	# tmp187
	shrq	%rdx	# tmp188
	orq	%rax, %rdx	# tmp189, tmp188
	cvtsi2sdq	%rdx, %xmm1	# tmp188, tmp187
	addsd	%xmm1, %xmm1	# tmp187, tmp186
	jmp	.L22	#
	.p2align 4,,10
	.p2align 3
.L33:
	movq	%rax, %rcx	# __z, tmp227
	andl	$1, %eax	#, tmp228
	pxor	%xmm0, %xmm0	# tmp226
	shrq	%rcx	# tmp227
	orq	%rax, %rcx	# tmp228, tmp227
	cvtsi2sdq	%rcx, %xmm0	# tmp227, tmp226
	addsd	%xmm0, %xmm0	# tmp226, tmp225
	jmp	.L34	#
	.p2align 4,,10
	.p2align 3
.L51:
# /usr/include/c++/13/bits/random.tcc:459: 	_M_gen_rand();
	movq	%r12, %rdi	# tmp247,
	movsd	%xmm1, 8(%rsp)	# __sum, %sfp
	call	_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv	#
# /usr/include/c++/13/bits/random.tcc:462:       result_type __z = _M_x[_M_p++];
	movq	10016(%rsp), %rcx	# gen._M_p, _186
	movsd	.LC8(%rip), %xmm2	#, tmp250
	movsd	8(%rsp), %xmm1	# %sfp, __sum
	jmp	.L32	#
	.p2align 4,,10
	.p2align 3
.L52:
# /usr/include/c++/13/bits/random.tcc:459: 	_M_gen_rand();
	movq	%r12, %rdi	# tmp247,
	call	_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv	#
# /usr/include/c++/13/bits/random.tcc:462:       result_type __z = _M_x[_M_p++];
	movq	10016(%rsp), %rdx	# gen._M_p, _215
	movsd	.LC8(%rip), %xmm2	#, tmp250
	jmp	.L20	#
	.p2align 4,,10
	.p2align 3
.L53:
# /usr/include/c++/13/bits/random.tcc:459: 	_M_gen_rand();
	movq	%r12, %rdi	# tmp247,
	movsd	%xmm1, 8(%rsp)	# __sum, %sfp
	call	_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv	#
# /usr/include/c++/13/bits/random.tcc:462:       result_type __z = _M_x[_M_p++];
	movq	10016(%rsp), %rcx	# gen._M_p, _39
	movsd	.LC8(%rip), %xmm2	#, tmp250
	movsd	8(%rsp), %xmm1	# %sfp, __sum
	jmp	.L23	#
	.p2align 4,,10
	.p2align 3
.L54:
# /usr/include/c++/13/bits/random.tcc:459: 	_M_gen_rand();
	movq	%r12, %rdi	# tmp247,
	call	_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv	#
# /usr/include/c++/13/bits/random.tcc:462:       result_type __z = _M_x[_M_p++];
	movq	10016(%rsp), %rdx	# gen._M_p, __i
	movsd	.LC8(%rip), %xmm2	#, tmp250
	jmp	.L29	#
	.p2align 4,,10
	.p2align 3
.L41:
	movsd	.LC4(%rip), %xmm0	#, _301
	jmp	.L35	#
	.p2align 4,,10
	.p2align 3
.L26:
# daxpy.cpp:25: 	Y[i] = dis(gen);
	movq	.LC4(%rip), %rax	#, tmp274
# daxpy.cpp:22:   for (int i = 0; i < N; ++i)
	addq	$8, %r14	#, ivtmp.210
# daxpy.cpp:25: 	Y[i] = dis(gen);
	movq	%rax, -8(%r14,%rbx)	# tmp274, MEM[(double *)&Y + ivtmp.210_261 * 1]
# daxpy.cpp:22:   for (int i = 0; i < N; ++i)
	cmpq	$32768, %r14	#, ivtmp.210
	jne	.L19	#,
.L28:
# daxpy.cpp:28:   ROI_BEGIN();            // ROI begin
	xorl	%esi, %esi	#
	xorl	%edi, %edi	#
	call	m5_dump_reset_stats@PLT	#
	movsd	.LC10(%rip), %xmm1	#, tmp252
	leaq	75568(%rsp), %r12	#, _262
	movq	%rbx, %rax	# ivtmp.193, ivtmp.199
	unpcklpd	%xmm1, %xmm1	# tmp252
	.p2align 4,,10
	.p2align 3
.L36:
# daxpy.cpp:33: 	Y[i] = alpha * X[i] + Y[i];
	movapd	0(%rbp), %xmm0	# MEM <vector(2) double> [(double *)_266], vect__3.178
	addq	$16, %rax	#, ivtmp.199
	addq	$16, %rbp	#, ivtmp.201
	mulpd	%xmm1, %xmm0	# tmp252, vect__3.178
# daxpy.cpp:33: 	Y[i] = alpha * X[i] + Y[i];
	addpd	-16(%rax), %xmm0	# MEM <vector(2) double> [(double *)_265], vect__5.182
# daxpy.cpp:33: 	Y[i] = alpha * X[i] + Y[i];
	movaps	%xmm0, -16(%rax)	# vect__5.182, MEM <vector(2) double> [(double *)_265]
	cmpq	%r12, %rax	# _262, ivtmp.199
	jne	.L36	#,
# daxpy.cpp:37:   ROI_END();           // ROI end
	xorl	%esi, %esi	#
	xorl	%edi, %edi	#
	call	m5_dump_reset_stats@PLT	#
# daxpy.cpp:39:   double sum = 0;
	pxor	%xmm0, %xmm0	# sum
	.p2align 4,,10
	.p2align 3
.L37:
	addsd	(%rbx), %xmm0	# BIT_FIELD_REF <MEM <vector(2) double> [(double *)_297], 64, 0>, stmp_sum_22.174
	addq	$16, %rbx	#, ivtmp.193
# daxpy.cpp:42: 	sum += Y[i];
	addsd	-8(%rbx), %xmm0	# BIT_FIELD_REF <MEM <vector(2) double> [(double *)_297], 64, 64>, sum
	cmpq	%rbx, %r12	# ivtmp.193, _262
	jne	.L37	#,
# /usr/include/x86_64-linux-gnu/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	leaq	.LC11(%rip), %rsi	#, tmp239
	movl	$2, %edi	#,
	movl	$1, %eax	#,
	call	__printf_chk@PLT	#
.LEHE3:
# /usr/include/c++/13/bits/random.h:1664:     { _M_fini(); }
	movq	%r13, %rdi	# tmp253,
	call	_ZNSt13random_device7_M_finiEv@PLT	#
# daxpy.cpp:46: }
	movq	75576(%rsp), %rax	# D.84413, tmp259
	subq	%fs:40, %rax	# MEM[(<address-space-1> long unsigned int *)40B], tmp259
	jne	.L56	#,
	addq	$75584, %rsp	#,
	.cfi_remember_state
	.cfi_def_cfa_offset 48
	xorl	%eax, %eax	#
	popq	%rbx	#
	.cfi_def_cfa_offset 40
	popq	%rbp	#
	.cfi_def_cfa_offset 32
	popq	%r12	#
	.cfi_def_cfa_offset 24
	popq	%r13	#
	.cfi_def_cfa_offset 16
	popq	%r14	#
	.cfi_def_cfa_offset 8
	ret	
.L56:
	.cfi_restore_state
	call	__stack_chk_fail@PLT	#
.L42:
	endbr64	
# /usr/include/c++/13/bits/random.h:1664:     { _M_fini(); }
	movq	%rax, %rbx	# tmp257, tmp243
	jmp	.L38	#
	.section	.gcc_except_table,"a",@progbits
.LLSDA3474:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE3474-.LLSDACSB3474
.LLSDACSB3474:
	.uleb128 .LEHB2-.LFB3474
	.uleb128 .LEHE2-.LEHB2
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB3-.LFB3474
	.uleb128 .LEHE3-.LEHB3
	.uleb128 .L42-.LFB3474
	.uleb128 0
.LLSDACSE3474:
	.section	.text.startup
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDAC3474
	.type	main.cold, @function
main.cold:
.LFSB3474:
.L38:
	.cfi_def_cfa_offset 75632
	.cfi_offset 3, -48
	.cfi_offset 6, -40
	.cfi_offset 12, -32
	.cfi_offset 13, -24
	.cfi_offset 14, -16
	movq	%r13, %rdi	# tmp253,
	call	_ZNSt13random_device7_M_finiEv@PLT	#
	movq	75576(%rsp), %rax	# D.84413, tmp260
	subq	%fs:40, %rax	# MEM[(<address-space-1> long unsigned int *)40B], tmp260
	jne	.L57	#,
	movq	%rbx, %rdi	# tmp243,
.LEHB4:
	call	_Unwind_Resume@PLT	#
.LEHE4:
.L57:
	call	__stack_chk_fail@PLT	#
	.cfi_endproc
.LFE3474:
	.section	.gcc_except_table
.LLSDAC3474:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC3474-.LLSDACSBC3474
.LLSDACSBC3474:
	.uleb128 .LEHB4-.LCOLDB12
	.uleb128 .LEHE4-.LEHB4
	.uleb128 0
	.uleb128 0
.LLSDACSEC3474:
	.section	.text.unlikely
	.section	.text.startup
	.size	main, .-main
	.section	.text.unlikely
	.size	main.cold, .-main.cold
.LCOLDE12:
	.section	.text.startup
.LHOTE12:
	.section	.rodata.cst16,"aM",@progbits,16
	.align 16
.LC0:
	.quad	-2147483648
	.quad	-2147483648
	.align 16
.LC1:
	.quad	2147483647
	.quad	2147483647
	.align 16
.LC2:
	.quad	1
	.quad	1
	.align 16
.LC3:
	.quad	2567483615
	.quad	2567483615
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC4:
	.long	0
	.long	1073741824
	.align 8
.LC6:
	.long	0
	.long	1106247680
	.align 8
.LC7:
	.long	0
	.long	1005584384
	.align 8
.LC8:
	.long	0
	.long	1072693248
	.align 8
.LC10:
	.long	0
	.long	1071644672
	.hidden	DW.ref.__gxx_personality_v0
	.weak	DW.ref.__gxx_personality_v0
	.section	.data.rel.local.DW.ref.__gxx_personality_v0,"awG",@progbits,DW.ref.__gxx_personality_v0,comdat
	.align 8
	.type	DW.ref.__gxx_personality_v0, @object
	.size	DW.ref.__gxx_personality_v0, 8
DW.ref.__gxx_personality_v0:
	.quad	__gxx_personality_v0
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
