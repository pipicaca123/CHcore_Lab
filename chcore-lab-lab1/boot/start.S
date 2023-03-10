#include <common/asm.h>

.extern arm64_elX_to_el1
.extern boot_cpu_stack
.extern secondary_boot_flag
.extern clear_bss_flag
.extern init_c
//mpidr_el1: In a multiprocessor system, provides an additional PE identification mechanism for scheduling purposes.
// PE: process element
// in A53-core MPIDR_EL1 is use for observe the activate core number.
BEGIN_FUNC(_start)
	mrs	x8, mpidr_el1 //if mpidr_el1 == 0x00: it is A cluster with one core only
	and	x8, x8,	#0xFF
	cbz	x8, primary

  /* hang all secondary processors before we intorduce multi-processors */
secondary_hang:
	bl secondary_hang

primary:

	/* Turn to el1 from other exception levels. */
	bl 	arm64_elX_to_el1

	/* Prepare stack pointer and jump to C. */
	adr 	x0, boot_cpu_stack
	add 	x0, x0, #0x1000
	mov 	sp, x0

	bl 	init_c

	/* Should never be here */
	b	.
END_FUNC(_start)
