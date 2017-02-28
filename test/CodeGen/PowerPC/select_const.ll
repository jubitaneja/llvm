; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=powerpc64le-unknown-unknown -verify-machineinstrs -mattr=+isel | FileCheck %s --check-prefix=ALL --check-prefix=ISEL
; RUN: llc < %s -mtriple=powerpc64le-unknown-unknown -verify-machineinstrs -mattr=-isel | FileCheck %s --check-prefix=ALL --check-prefix=NO_ISEL

; Select of constants: control flow / conditional moves can always be replaced by logic+math (but may not be worth it?).
; Test the zeroext/signext variants of each pattern to see if that makes a difference.

; select Cond, 0, 1 --> zext (!Cond)

define i32 @select_0_or_1(i1 %cond) {
; ALL-LABEL: select_0_or_1:
; ALL:       # BB#0:
; ALL-NEXT:    not 3, 3
; ALL-NEXT:    clrldi 3, 3, 63
; ALL-NEXT:    blr
  %sel = select i1 %cond, i32 0, i32 1
  ret i32 %sel
}

define i32 @select_0_or_1_zeroext(i1 zeroext %cond) {
; ALL-LABEL: select_0_or_1_zeroext:
; ALL:       # BB#0:
; ALL-NEXT:    xori 3, 3, 1
; ALL-NEXT:    blr
  %sel = select i1 %cond, i32 0, i32 1
  ret i32 %sel
}

define i32 @select_0_or_1_signext(i1 signext %cond) {
; ALL-LABEL: select_0_or_1_signext:
; ALL:       # BB#0:
; ALL-NEXT:    not 3, 3
; ALL-NEXT:    clrldi 3, 3, 63
; ALL-NEXT:    blr
  %sel = select i1 %cond, i32 0, i32 1
  ret i32 %sel
}

; select Cond, 1, 0 --> zext (Cond)

define i32 @select_1_or_0(i1 %cond) {
; ALL-LABEL: select_1_or_0:
; ALL:       # BB#0:
; ALL-NEXT:    clrldi 3, 3, 63
; ALL-NEXT:    blr
  %sel = select i1 %cond, i32 1, i32 0
  ret i32 %sel
}

define i32 @select_1_or_0_zeroext(i1 zeroext %cond) {
; ALL-LABEL: select_1_or_0_zeroext:
; ALL:       # BB#0:
; ALL-NEXT:    blr
  %sel = select i1 %cond, i32 1, i32 0
  ret i32 %sel
}

define i32 @select_1_or_0_signext(i1 signext %cond) {
; ALL-LABEL: select_1_or_0_signext:
; ALL:       # BB#0:
; ALL-NEXT:    clrldi 3, 3, 63
; ALL-NEXT:    blr
  %sel = select i1 %cond, i32 1, i32 0
  ret i32 %sel
}

; select Cond, 0, -1 --> sext (!Cond)

define i32 @select_0_or_neg1(i1 %cond) {
; ISEL-LABEL: select_0_or_neg1:
; ISEL:       # BB#0:
; ISEL-NEXT:    li 4, 0
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    oris 3, 4, 65535
; ISEL-NEXT:    ori 3, 3, 65535
; ISEL-NEXT:    isel 3, 0, 3, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_0_or_neg1:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    li 4, 0
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    oris 3, 4, 65535
; NO_ISEL-NEXT:    ori 3, 3, 65535
; NO_ISEL-NEXT:    bc 12, 1, .LBB6_1
; NO_ISEL-NEXT:    blr
; NO_ISEL-NEXT:  .LBB6_1:
; NO_ISEL-NEXT:    addi 3, 0, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 0, i32 -1
  ret i32 %sel
}

define i32 @select_0_or_neg1_zeroext(i1 zeroext %cond) {
; ISEL-LABEL: select_0_or_neg1_zeroext:
; ISEL:       # BB#0:
; ISEL-NEXT:    li 4, 0
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    oris 3, 4, 65535
; ISEL-NEXT:    ori 3, 3, 65535
; ISEL-NEXT:    isel 3, 0, 3, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_0_or_neg1_zeroext:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    li 4, 0
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    oris 3, 4, 65535
; NO_ISEL-NEXT:    ori 3, 3, 65535
; NO_ISEL-NEXT:    bc 12, 1, .LBB7_1
; NO_ISEL-NEXT:    blr
; NO_ISEL-NEXT:  .LBB7_1:
; NO_ISEL-NEXT:    addi 3, 0, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 0, i32 -1
  ret i32 %sel
}

define i32 @select_0_or_neg1_signext(i1 signext %cond) {
; ISEL-LABEL: select_0_or_neg1_signext:
; ISEL:       # BB#0:
; ISEL-NEXT:    li 4, 0
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    oris 3, 4, 65535
; ISEL-NEXT:    ori 3, 3, 65535
; ISEL-NEXT:    isel 3, 0, 3, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_0_or_neg1_signext:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    li 4, 0
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    oris 3, 4, 65535
; NO_ISEL-NEXT:    ori 3, 3, 65535
; NO_ISEL-NEXT:    bc 12, 1, .LBB8_1
; NO_ISEL-NEXT:    blr
; NO_ISEL-NEXT:  .LBB8_1:
; NO_ISEL-NEXT:    addi 3, 0, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 0, i32 -1
  ret i32 %sel
}

; select Cond, -1, 0 --> sext (Cond)

define i32 @select_neg1_or_0(i1 %cond) {
; ISEL-LABEL: select_neg1_or_0:
; ISEL:       # BB#0:
; ISEL-NEXT:    li 4, 0
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    oris 3, 4, 65535
; ISEL-NEXT:    ori 3, 3, 65535
; ISEL-NEXT:    isel 3, 3, 4, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_neg1_or_0:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    li 4, 0
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    oris 3, 4, 65535
; NO_ISEL-NEXT:    ori 3, 3, 65535
; NO_ISEL-NEXT:    bclr 12, 1, 0
; NO_ISEL-NEXT:  # BB#1:
; NO_ISEL-NEXT:    ori 3, 4, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 -1, i32 0
  ret i32 %sel
}

define i32 @select_neg1_or_0_zeroext(i1 zeroext %cond) {
; ISEL-LABEL: select_neg1_or_0_zeroext:
; ISEL:       # BB#0:
; ISEL-NEXT:    li 4, 0
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    oris 3, 4, 65535
; ISEL-NEXT:    ori 3, 3, 65535
; ISEL-NEXT:    isel 3, 3, 4, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_neg1_or_0_zeroext:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    li 4, 0
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    oris 3, 4, 65535
; NO_ISEL-NEXT:    ori 3, 3, 65535
; NO_ISEL-NEXT:    bclr 12, 1, 0
; NO_ISEL-NEXT:  # BB#1:
; NO_ISEL-NEXT:    ori 3, 4, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 -1, i32 0
  ret i32 %sel
}

define i32 @select_neg1_or_0_signext(i1 signext %cond) {
; ISEL-LABEL: select_neg1_or_0_signext:
; ISEL:       # BB#0:
; ISEL-NEXT:    li 4, 0
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    oris 3, 4, 65535
; ISEL-NEXT:    ori 3, 3, 65535
; ISEL-NEXT:    isel 3, 3, 4, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_neg1_or_0_signext:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    li 4, 0
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    oris 3, 4, 65535
; NO_ISEL-NEXT:    ori 3, 3, 65535
; NO_ISEL-NEXT:    bclr 12, 1, 0
; NO_ISEL-NEXT:  # BB#1:
; NO_ISEL-NEXT:    ori 3, 4, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 -1, i32 0
  ret i32 %sel
}

; select Cond, C+1, C --> add (zext Cond), C

define i32 @select_Cplus1_C(i1 %cond) {
; ISEL-LABEL: select_Cplus1_C:
; ISEL:       # BB#0:
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    li 4, 42
; ISEL-NEXT:    li 3, 41
; ISEL-NEXT:    isel 3, 4, 3, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_Cplus1_C:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    li 4, 42
; NO_ISEL-NEXT:    li 3, 41
; NO_ISEL-NEXT:    bc 12, 1, .LBB12_1
; NO_ISEL-NEXT:    blr
; NO_ISEL-NEXT:  .LBB12_1:
; NO_ISEL-NEXT:    addi 3, 4, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 42, i32 41
  ret i32 %sel
}

define i32 @select_Cplus1_C_zeroext(i1 zeroext %cond) {
; ISEL-LABEL: select_Cplus1_C_zeroext:
; ISEL:       # BB#0:
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    li 4, 42
; ISEL-NEXT:    li 3, 41
; ISEL-NEXT:    isel 3, 4, 3, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_Cplus1_C_zeroext:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    li 4, 42
; NO_ISEL-NEXT:    li 3, 41
; NO_ISEL-NEXT:    bc 12, 1, .LBB13_1
; NO_ISEL-NEXT:    blr
; NO_ISEL-NEXT:  .LBB13_1:
; NO_ISEL-NEXT:    addi 3, 4, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 42, i32 41
  ret i32 %sel
}

define i32 @select_Cplus1_C_signext(i1 signext %cond) {
; ISEL-LABEL: select_Cplus1_C_signext:
; ISEL:       # BB#0:
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    li 4, 42
; ISEL-NEXT:    li 3, 41
; ISEL-NEXT:    isel 3, 4, 3, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_Cplus1_C_signext:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    li 4, 42
; NO_ISEL-NEXT:    li 3, 41
; NO_ISEL-NEXT:    bc 12, 1, .LBB14_1
; NO_ISEL-NEXT:    blr
; NO_ISEL-NEXT:  .LBB14_1:
; NO_ISEL-NEXT:    addi 3, 4, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 42, i32 41
  ret i32 %sel
}

; select Cond, C, C+1 --> add (sext Cond), C

define i32 @select_C_Cplus1(i1 %cond) {
; ISEL-LABEL: select_C_Cplus1:
; ISEL:       # BB#0:
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    li 4, 41
; ISEL-NEXT:    li 3, 42
; ISEL-NEXT:    isel 3, 4, 3, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_C_Cplus1:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    li 4, 41
; NO_ISEL-NEXT:    li 3, 42
; NO_ISEL-NEXT:    bc 12, 1, .LBB15_1
; NO_ISEL-NEXT:    blr
; NO_ISEL-NEXT:  .LBB15_1:
; NO_ISEL-NEXT:    addi 3, 4, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 41, i32 42
  ret i32 %sel
}

define i32 @select_C_Cplus1_zeroext(i1 zeroext %cond) {
; ISEL-LABEL: select_C_Cplus1_zeroext:
; ISEL:       # BB#0:
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    li 4, 41
; ISEL-NEXT:    li 3, 42
; ISEL-NEXT:    isel 3, 4, 3, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_C_Cplus1_zeroext:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    li 4, 41
; NO_ISEL-NEXT:    li 3, 42
; NO_ISEL-NEXT:    bc 12, 1, .LBB16_1
; NO_ISEL-NEXT:    blr
; NO_ISEL-NEXT:  .LBB16_1:
; NO_ISEL-NEXT:    addi 3, 4, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 41, i32 42
  ret i32 %sel
}

define i32 @select_C_Cplus1_signext(i1 signext %cond) {
; ISEL-LABEL: select_C_Cplus1_signext:
; ISEL:       # BB#0:
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    li 4, 41
; ISEL-NEXT:    li 3, 42
; ISEL-NEXT:    isel 3, 4, 3, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_C_Cplus1_signext:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    li 4, 41
; NO_ISEL-NEXT:    li 3, 42
; NO_ISEL-NEXT:    bc 12, 1, .LBB17_1
; NO_ISEL-NEXT:    blr
; NO_ISEL-NEXT:  .LBB17_1:
; NO_ISEL-NEXT:    addi 3, 4, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 41, i32 42
  ret i32 %sel
}

; In general, select of 2 constants could be:
; select Cond, C1, C2 --> add (mul (zext Cond), C1-C2), C2 --> add (and (sext Cond), C1-C2), C2

define i32 @select_C1_C2(i1 %cond) {
; ISEL-LABEL: select_C1_C2:
; ISEL:       # BB#0:
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    li 4, 421
; ISEL-NEXT:    li 3, 42
; ISEL-NEXT:    isel 3, 4, 3, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_C1_C2:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    li 4, 421
; NO_ISEL-NEXT:    li 3, 42
; NO_ISEL-NEXT:    bc 12, 1, .LBB18_1
; NO_ISEL-NEXT:    blr
; NO_ISEL-NEXT:  .LBB18_1:
; NO_ISEL-NEXT:    addi 3, 4, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 421, i32 42
  ret i32 %sel
}

define i32 @select_C1_C2_zeroext(i1 zeroext %cond) {
; ISEL-LABEL: select_C1_C2_zeroext:
; ISEL:       # BB#0:
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    li 4, 421
; ISEL-NEXT:    li 3, 42
; ISEL-NEXT:    isel 3, 4, 3, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_C1_C2_zeroext:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    li 4, 421
; NO_ISEL-NEXT:    li 3, 42
; NO_ISEL-NEXT:    bc 12, 1, .LBB19_1
; NO_ISEL-NEXT:    blr
; NO_ISEL-NEXT:  .LBB19_1:
; NO_ISEL-NEXT:    addi 3, 4, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 421, i32 42
  ret i32 %sel
}

define i32 @select_C1_C2_signext(i1 signext %cond) {
; ISEL-LABEL: select_C1_C2_signext:
; ISEL:       # BB#0:
; ISEL-NEXT:    andi. 3, 3, 1
; ISEL-NEXT:    li 4, 421
; ISEL-NEXT:    li 3, 42
; ISEL-NEXT:    isel 3, 4, 3, 1
; ISEL-NEXT:    blr
;
; NO_ISEL-LABEL: select_C1_C2_signext:
; NO_ISEL:       # BB#0:
; NO_ISEL-NEXT:    andi. 3, 3, 1
; NO_ISEL-NEXT:    li 4, 421
; NO_ISEL-NEXT:    li 3, 42
; NO_ISEL-NEXT:    bc 12, 1, .LBB20_1
; NO_ISEL-NEXT:    blr
; NO_ISEL-NEXT:  .LBB20_1:
; NO_ISEL-NEXT:    addi 3, 4, 0
; NO_ISEL-NEXT:    blr
  %sel = select i1 %cond, i32 421, i32 42
  ret i32 %sel
}
