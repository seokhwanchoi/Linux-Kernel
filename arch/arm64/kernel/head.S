//EFI관련 코드를 제외하면 시작위치는 stext
/*

1. 소스코드( .c ) - 사용자에 의해 c언어로 작성된 소스 코드로 확장자가 c이다.
ex> hello.c

전처리 (Preprocessing)

2. 전처리 후 소스( .i ) - 전처리가 끝이 나면 i 확장자를 가진 파일이 생성된다.
본격적으로 C언어를 기계어로 변환하기 시작한다.

C 컴파일 (Compile)

3. 어셈블리소스 ( .s ) - 기계어와 가장 유사한 상태인 어셈블리어로 변환 된 s 확장자를 가진
파일이 생성된다.

어셈블리 (Assembly) 컴파일

4. 오브젝트 파일( .o ) - 2진수로 이루어진 기계어로 된 파일이 생성된다. 확장자는 o이다.

링크 (Link)

5. 실행파일 ( .exe ) - 링크에 의해 실행 할 수 있는 파일을 생성한다.

어셈블리어는 대소문자 구분하지 않는듯?

<어셈블리어>
bl : branch with link(지정된 주소로 점프하면서 동시에 다음 명령어의 주소를
레지스터에 저장하는 멸령어)

http://blog.daum.net/tlos6733/132 참고

 아래 코드가 실행되면 x0은 0xFFFFFF97D91E7000로 업데이트됩니다.
adrp 명령어는 주소를 복사하는 역할을 수행합니다.
9 NSX:FFFFFF97D6ACC190|   adrp    x0,0xFFFFFF97D91E7000

AND x1,x2,x3     x1=x2 & X3
*/

/* stext 프로시저*/
ENTRY(stext)//stext 프로시저는 ENTRY(심볼 이름)...ENDPROC(심볼이름)의 형태로 둘러싸여있다.
	bl	preserve_boot_args            //부트로더에 의해 전달된 부트 파라미터를 저장
	bl	el2_setup		        // Drop to EL1, w0=cpu_boot_mode
	adrp	x23, __PHYS_OFFSET
	and	x23, x23, MIN_KIMG_ALIGN - 1	// KASLR offset, defaults to 0
	bl	set_cpu_boot_mode_flag        //기록
	bl	__create_page_tables	      //페이지테이블 생성
	bl	__cpu_setup			// initialise processor
	b	__primary_switch
ENDPROC(stext)


/* preserve_boot_args 프로시저*/
preserve_boot_args:
	mov	x21, x0				// x21=FDT

	adr_l	x0, boot_args			// record the contents of
	stp	x21, x1, [x0]			// x0 .. x3 at kernel entry
	stp	x2, x3, [x0, #16]

	dmb	sy				// needed before dc ivac with
						// MMU off

	mov	x1, #0x20			// 4 x 8 bytes
	b	__inval_dcache_area		// tail call
ENDPROC(preserve_boot_args)

/*
 첫 분기점인 preserve_boot_args 프로시저는 커널 부팅을 위해 전달된 부트 파라미터를 저장
 x0레지스터만 물리주소로 명시, 나머지 레지스터는 나중에 사용하기 위해 예약
*/
