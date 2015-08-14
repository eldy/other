SaveRegisters macro
pushf
;pusha
push    ax
push    bx 
push    cx
push    dx 
;----
push    ds
push    es 
push    di
push    si
push    bp
endm
  
RestoreRegisters macro
pop     bp
pop     si
pop     di
pop     es
pop     ds
;popa
pop     dx
pop     cx
pop     bx
pop     ax
;----
popf
endm

  
SaveDTA macro
mov	ah,2Fh
int	21h
push	es
push	bx
endm
  
RestoreDTA macro  
;Replace DTA dans zone d'origine (normallement 80h du PSP DX=80h,AH=1Ah)
pop	dx
pop	ds
mov	ah,1Ah
int	21h
endm             

  
SavePSP macro
xor     si,si
mov     di,dx
mov     cx,256
copie_savepsp:
lodsb              
stosb              
dec     cx
jnz     copie_savepsp  
endm                 
                     
RestorePSP macro     
xor     di,di        
mov     si,dx        
mov     cx,256
copie_restorepsp:
lodsb                 
stosb                 
dec     cx    
jnz     copie_restorepsp
endm
