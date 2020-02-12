//EFI관련 코드를 제외하면 시작위치는 stext

ENTRY(stext)
	bl	preserve_boot_args            //부트로더에 의해 전달된 부트 파라미터를 저장
	bl	el2_setup			                // Drop to EL1, w0=cpu_boot_mode
	adrp	x23, __PHYS_OFFSET
	and	x23, x23, MIN_KIMG_ALIGN - 1	// KASLR offset, defaults to 0
	bl	set_cpu_boot_mode_flag        //
	bl	__create_page_tables
