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
*/

ENTRY(stext)
	bl	preserve_boot_args            //부트로더에 의해 전달된 부트 파라미터를 저장
	bl	el2_setup		        // Drop to EL1, w0=cpu_boot_mode
	adrp	x23, __PHYS_OFFSET
	and	x23, x23, MIN_KIMG_ALIGN - 1	// KASLR offset, defaults to 0
	bl	set_cpu_boot_mode_flag        //
	bl	__create_page_tables
