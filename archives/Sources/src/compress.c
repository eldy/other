//--------------------------------------------------------
// Compress/Uncompress functions library
//--------------------------------------------------------
// 11/11/99	1.0	Laurent Destailleur	Creation
//--------------------------------------------------------
// <<< All OS >>>
// Compresse_LZW
// Decompresse_LZW
//--------------------------------------------------------

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <ctype.h>

#include "compress.h"
#include "hardware.h"
#include "macros.h"

#ifdef BUFSIZ
#undef BUFSIZ
#endif
#define BUFSIZ 4096


// LZW et HUFFMAN

typedef enum {false,true} T_Bool;
unsigned char Buffer_Ecri[BUFSIZ];


// LZW

#define MAX_DICO       765 	//765  ces 2 donnees doivent etre coherentes
#define MAX_BITS       10  	//10   MAX_DICO = 2 puissance MAX_BITS - 259
#define MAX_CHAINE     32
#define MAX_COLLISION  37   /* maximum de collisions autorisees */
#define SONDE          31   /* incrementation lors d'une collision */
			    			/* Ce nombre doit etre premier avec la taille de la table */
/* Definition de la structure du dictionnaire */
typedef struct S_Table {
  unsigned char Chaine[MAX_CHAINE]; /* taille maxi d'une chaine */
  unsigned char Lg;                 /* longuer d'une chaine */
  unsigned char NbCollision; 		/* nombre de collision  */
  } T_Table;
T_Table Dico[MAX_DICO];

/* buffer de lecture en compression et decompression */
static unsigned char Buffer_LectC[BUFSIZ];
static unsigned int  Buffer_LectD[BUFSIZ];
/* Autres buffers */
static unsigned char Buffer_Ecri2[BUFSIZ];


// HUFFMAN

/* Taille max theorique du fichier =                       */
/* 1+1+1+2+3+5+8+13+21+34+55+89+144+233+377+610+987+1597   */
/* +2584+4181+6765+10946+17711+28657+46368+75025+121393    */
/* +196418+317811+514229+832040+1346269+2178309 (=5702887) */
/* +...                                                    */
/*       (65 termes car 64 bits pour codage)               */
/* Exemple: avec taille fichier de 5702887, MAXCODE = 32   */
#define MAXCODE       65   /* 64 bits maximum + niveau racine   */
#define LONGCODE      6    /* Nombre de bits pour coder MAXCODE */
#define TAILLE_ASCII  255
#define FIN_FICHIER   0x1A

/* declaration des types de donn‚es pour construire l'arbre */
/* definition d'une feuille */
typedef struct S_Feuille   /* feuille de l'arbre : soit un noeud, soit une donnee */
  {
  T_Bool Noeud;      /*  vrai = noeud, faux = feuille */
  union {
    unsigned char Data;    /* donnee d'une feuille   */
    struct S_Noeud * Ptr;  /* ptr sur un autre noeud */
    } U_Feuille;
  } T_Feuille;                 /* Structure de 1+1+4=6 octets */
/* definition d'un noeud de l'arbre */
typedef struct S_Noeud
  {
  T_Feuille FDroite;         /* feuille droite de l'arbre */
  T_Feuille FGauche;         /* feuille gauche de l'arbre */
  char CodeNoeud[MAXCODE];        /* codage jusqu'au noeud */
  } T_Noeud;                  /* Structure de 2x6+MAXCODE octets */
typedef struct  {
	 long  Cumul;        /* frequence d'apparition des caracteres */
	 T_Feuille Donnee;  /* donn‚e ou noeud pour calculer l'arbre */
	 char Code[MAXCODE];     /* code trouve pour le caractere         */
	 T_Bool Codifie;    /* true = codification existante         */
	 } T_ASCII;          /* Structure de 4+6+MAXCODE+1 octets */


T_ASCII ASCII[TAILLE_ASCII+1]; /* table des fr‚q des codes ASCII lus */
unsigned char Buffer_Lect[BUFSIZ];
int DimAscii=0;    /* nombre de caracteres differents */
long TotalOctet=0; /* nombre d'octets lus du fichier initial */
T_Noeud *PtrNoeud;   /* ptr noeud pour construire l'arbre */
T_Noeud *Racine;     /* racine de l'arbre */



// LZW



void Init_Dico (T_Table *Dico)
/* --------------------------------------------------*/
/* Init_Dico : Initialisation du dictionnaire.       */
/*-------------------------------------------------- */
{
int i;
for (i=0;i<MAX_DICO;i++) {
  (Dico+i)->Lg=(Dico+i)->NbCollision=0;
  }
}


void Emettre_Rang (FILE *FCible,unsigned int Rang)
/* -------------------------------------------------------*/
/* Emettre_Rang : Emet les rangs calcules, dans un buffer */
/* ============   temporaire puis dans un fichier.        */
/*------------------------------------------------------- */
{
unsigned int Bit_A_1[16]={1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768};
static int C_A_Ecrire=0; /* nombre de caract a ecrire du buffer sur support magnetique */
static unsigned int En_Cours=0;   /* rang en cours de creation     */
/* indice pointant sur le bit courant de En_Cours */
static unsigned int Cpt_EnCours = 15;
int i;                  /* indice courant */

for (i=0;i<MAX_BITS;i++) {
  /* stocke MAX_BITS bits de poids faible de Rang */
  if (Rang & Bit_A_1[i])   /* bit a 1 positionne */
    En_Cours |= Bit_A_1[Cpt_EnCours];
  /* En_Cours plein */
  if ( ! Cpt_EnCours-- ) {
    Buffer_Ecri[C_A_Ecrire++] = En_Cours;
    if (C_A_Ecrire == BUFSIZ) {
      fwrite (Buffer_Ecri, sizeof(unsigned int),BUFSIZ, FCible);
      C_A_Ecrire = 0;
      }
    Cpt_EnCours = 15;
    En_Cours = 0;
    }
  }
  /* si dernier caractere = fin de fichier */
if ((Rang == 256) && (C_A_Ecrire)) {
  if (En_Cours) Buffer_Ecri[C_A_Ecrire++]=En_Cours;
  fwrite(Buffer_Ecri, sizeof(unsigned int), C_A_Ecrire, FCible);
  }
}


T_Bool strcomp (unsigned char *Chaine1,unsigned char Lg1,unsigned char *Chaine2,unsigned char Lg2)
/* ------------------------------------------------- */
/* strcomp : comparaison de 2 tableaux de donnees    */
/* ------------------------------------------------- */
{
int l = 0;
T_Bool Egal=true;
if (Lg1 == Lg2) {
  while ( ( l < Lg1) && Egal) {
    if ( *(Chaine1+l) != *(Chaine2+l))  Egal=false;
    l++;
    }
  }
else Egal=false;
return(Egal);
}


/* --------------------------------------------------*/
/* Hash_Coding : Fonction de calcul de l'indice de   */
/* ===========   rangement dans la table en fonction */
/* de la cl‚. On donne un poids … chaque caract‚re.  */
/*-------------------------------------------------- */
unsigned int Hash_Coding (unsigned char *Chaine,unsigned char LgChaine)
{
unsigned long Somme=0;
unsigned char i;
for (i=0;i<LgChaine;i++) {
  Somme+=((unsigned long) *(Chaine+i) << i);
  Somme%=MAX_DICO;
  }
return ((unsigned int) Somme);
}


T_Bool Recherche_Chaine (unsigned char *Chaine,unsigned char LgChaine,T_Table *Dico,int *Rang)
//-------------------------------------------------
// Recherche_Chaine : Recherche si une chaine est localisee dans le tableau
//                    et a quel rang.
//-------------------------------------------------
{
T_Bool        Trouve = false;
unsigned int  Indice = Hash_Coding ( Chaine, LgChaine);
int           NC;         /* nombre de collisions */

*Rang = 0;
if ( ! strcomp ((Dico+Indice)->Chaine, (Dico+Indice)->Lg,Chaine,LgChaine)) {
  /* chaine pas trouvee … l'endroit estim‚e : */
  /* peut etre probl‚me de collision          */
  NC = (Dico+Indice) -> NbCollision;
  if (NC) do {
    /* calcul de l'indice est bon, mais la chaine n'est pas bonne */
    Indice += SONDE;
    Indice %= MAX_DICO;
    NC--;
    if (strcomp((Dico+Indice)->Chaine,(Dico+Indice)->Lg,Chaine,LgChaine)) Trouve = true;
    }
    while ((NC) && ! Trouve);
  }
else Trouve=true; /* chaine trouvee au bon endroit */
*Rang=Indice+258;
return(Trouve);
}


void Inserer_Chaine (unsigned char *Chaine,unsigned char LgChaine,T_Table *Dico,int Indice)
/* ----------------------------------------------------*/
/* Inserer_Chaine : Copie de la chaine au rang indique */
/*---------------------------------------------------- */
{
/*   (Dico+Indice)->Chaine = (unsigned char *) calloc ((int) LgChaine, 1);*/
memcpy( (Dico+Indice)->Chaine,Chaine,(int) LgChaine);
(Dico+Indice)->Lg=LgChaine;
}


T_Bool Ajouter_Dico (unsigned char *Chaine,unsigned char LgChaine,T_Table *Dico,int *Rang)
/* --------------------------------------------------*/
/* Ajouter_Dico : Ajouter une chaine dans le dico au rang trouve dans Recherche_Dico */
/*-------------------------------------------------- */
{
     T_Bool    Trouve = true;
     int       Indice = Hash_Coding( Chaine, LgChaine);

     if ( ((Dico+ *Rang-258)->Lg == 0) &&
	  ((Dico+ *Rang-258)->NbCollision < MAX_COLLISION))
     {
	 Inserer_Chaine (Chaine, LgChaine, Dico, *Rang-258);

	/* mise … jour du nombre de collisions */
	 if (Indice != (*Rang-258)) (Dico+Indice)->NbCollision ++;
     }
     else
     {
	if ((Dico+Indice)->NbCollision == MAX_COLLISION)
	   Trouve = false;
	else
	{
	   /* recherche d'un emplacement libre ou dico plein */
	   int  i = *Rang -258;
	   int NC = (Dico+Indice)->NbCollision;

	   do
	   {
	       i += SONDE;
	       i %= MAX_DICO;
	       NC++;
	   }
	   while ((Dico+i)->Lg && (NC < MAX_COLLISION));

	   if ((Dico+i)->Lg == 0)
	   {
	      Inserer_Chaine( Chaine, LgChaine, Dico, i);
	      (Dico+Indice)->NbCollision = NC;
	      *Rang = i + 258;
	   }
	   else Trouve=false;
	}
     }
return(Trouve);
}


void Compresse_Donnees_LZW (FILE *FSource,FILE *FCible,T_Table *Dico)
//--------------------------------------------------
// Compresse_Donnees : Compression des donnees proprement dite.
//--------------------------------------------------
{
    int         NbreCaract; /* nbre de caract. lus dans le buffer d'entree */
    int         i;

	/* chaine constituee  du latent et du caractere */
    unsigned char Chaine[MAX_CHAINE] = "";
    unsigned char LgChaine = 0;
    unsigned char Latent[MAX_CHAINE] = "";     /* code latent      */
    unsigned char LgLatent = 0;
    int         Rang;    /* rang dans le dico de la chaine cherch‚e */
    int         AncRang;
    int         DernierRangCree = 0;
    unsigned char l = 0;
    #ifdef DEBUG
    int n = 0;
    #endif DEBUG

    do
    {
      /* lecture en bloc des donnees */

	if ((NbreCaract=fread(&Buffer_LectC,1,BUFSIZ,FSource)) > 0) {
	  #ifdef DEBUG
	  printf("Bloc de %i lus = %i\n", BUFSIZ, ++n);
	  #endif
	  /* traitement caractere par caractere */
	  for (i = 0; i < NbreCaract; i++) {
	      if ( LgLatent == 0)
	      {
		/* caractere a transcoder */
		  *Latent  = (unsigned char) Buffer_LectC[i];
		  LgLatent = 1;
		/* rang du caractere dans la table ascii =
			   1ere partie du dico */
		  AncRang = (unsigned int) Buffer_LectC[i];
	      }
	      else
	      {
		  /* copie de chaine */
		   for ( l=0; l < LgLatent; l++) Chaine[l] = Latent[l];
		   LgChaine = LgLatent;

		  /* concatenation */
		  Chaine[LgChaine++] = *(Buffer_LectC+i);

		 /* recherche de la chaine dans la dictionnaire */

		  if ( Recherche_Chaine( Chaine, LgChaine, Dico, &Rang))
		    /* chaine trouvee */
		  {
		     /* traitement de la repetition du meme caract */
		      if (Rang == DernierRangCree)
		      {
			 Emettre_Rang ( FCible, AncRang);
			 *Latent = *(Buffer_LectC+i);
			 LgLatent = 1;
			 AncRang = (unsigned int) Buffer_LectC[i];
			 DernierRangCree = 0;
		      }
		      else
		      {
			/* copie de chaine */
			 for ( l=0; l < LgChaine; l++) Latent[l] = Chaine[l];
			 LgLatent = LgChaine;
			 AncRang = Rang;
		      }
		   }
		   else
		   {
			Emettre_Rang ( FCible, AncRang);

		       /* test si le dico est plein -> RAZ */
			if ( ! Ajouter_Dico ( Chaine, LgChaine, Dico, &Rang))
			{
			   Emettre_Rang ( FCible, 257);  /* code de RAZ */
			   Init_Dico(Dico);

			  /* caractere a transcoder */
			   *Latent  = (unsigned char) Buffer_LectC[i];
			   LgLatent = 1;
			   LgChaine = 0;
			}
			else
			{
			   *Latent = *(Buffer_LectC+i);
			   LgLatent = 1;
			   DernierRangCree = Rang;
			}
			AncRang = (unsigned int) Buffer_LectC[i];

		    }
	      } /* fin de if (Latent ... */


	  } /* fin du for    */
	}
    }
    while ( NbreCaract > 0);

    Emettre_Rang ( FCible, AncRang);
    Emettre_Rang ( FCible, 256);   /* envoi du code de fin de fichier */
}


int Compression_LZW (char *chaine1,char *chaine2)
//---------------------------------------------------------------------------
// Compression_LZW : Traitement de la compression en utilisant la methode LZW
//---------------------------------------------------------------------------
{
FILE *FSource, *FCible;          /* declaration des fichiers */
FSource = fopen(chaine1,"rb");   /* ouverture en lecture */
if (FSource == NULL) return(1);
FCible = fopen(chaine2,"wb");    /* ouverture en ecriture */
if (FCible == NULL) return(2);
// Initilisation du dictionnaire
Init_Dico((T_Table *) &Dico);
// Compression de donnees proprement dite
Compresse_Donnees_LZW(FSource, FCible,(T_Table *) &Dico);
return(0);
}


int Recevoir_Rang (FILE *FSource)
//-------------------------------------------------------
// Recevoir_Rang : lit les rangs a partir d'un fichier compresse.
//-------------------------------------------------------
{
unsigned int Bit_A_1[16]={1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768};

 /* nombre de caract a lire du buffer */
  static int  C_A_Lire=0, Nbre_Car =1;
  static unsigned int Octet;
  int     Rang = 0;
  int     i = 0;                  /* indice courant */
  static  int Nbre_Bit = -1;
  #ifdef DEBUG
  int n = 0;
  #endif

  while ( i < MAX_BITS)
  {
       if (( Nbre_Car > C_A_Lire-1) && (Nbre_Bit < 0))
       {
	   C_A_Lire = fread ( &Buffer_LectD, sizeof(unsigned int),
			       BUFSIZ, FSource);
	   #ifdef DEBUG
	   printf("Bloc de %i lus = %i\n", BUFSIZ, ++n);
	   #endif
	   Nbre_Car = 0;
       }
       if (Nbre_Bit<0) {
	 Octet = Buffer_LectD[Nbre_Car++];
	 Nbre_Bit = 15;
	 }
      /* calcule du rang */
       if (Octet & Bit_A_1[Nbre_Bit--]) Rang|=Bit_A_1[i]; /* bit a 1 positionne */
       i++;
   }
return (Rang);
}


void Modifier_Dico (unsigned char *Chaine,unsigned char LgChaine,T_Table *Dico)
//--------------------------------------------------
// Modifier_Dico : Ajouter une chaine dans le dico si elle n'existe pas deja
//--------------------------------------------------
{
unsigned short Indice = Hash_Coding(Chaine, LgChaine);
unsigned short NC = (Dico+Indice)->NbCollision;
T_Bool         Trouve = false;
while (((Dico+Indice)->Lg) && (NC <= MAX_COLLISION) && ! Trouve) {
  if ( strcomp((Dico+Indice)->Chaine, (Dico+Indice)->Lg,Chaine,LgChaine)) Trouve=true;
  Indice += SONDE;
  Indice %= MAX_DICO;
  NC++;
  }
if (! Trouve) Inserer_Chaine (Chaine, LgChaine, Dico, Indice);
}


void Ecrire_Fichier(FILE *FCible,unsigned char *Chaine,unsigned char LgChaine,T_Bool FinFichier)
//--------------------------------------------------
// Ecrire_Fichier : Ecriture de la chaine de donnees decodees dans un fichier
//--------------------------------------------------
{
/* nombre de caract a lire du buffer */
static int C_A_Ecrire=0,l;
if (! FinFichier)
  for ( l = 0; l < LgChaine; l++) {
    if (C_A_Ecrire == BUFSIZ) {
      fwrite(Buffer_Ecri2, sizeof(char), BUFSIZ, FCible);
      C_A_Ecrire = 0;
      }
    Buffer_Ecri2[C_A_Ecrire++] = *(Chaine+l);
    }
else if (C_A_Ecrire) fwrite(Buffer_Ecri2, sizeof(char), C_A_Ecrire, FCible);
}


void DeCompresse_Donnees (FILE *FSource,FILE *FCible,T_Table *Dico)
//--------------------------------------------------
// DeCompresse_Donnees : DeCompression des donnees proprement dite.
//--------------------------------------------------
{
 /* chaine constituee  du latent et du caractere */
    unsigned char Chaine[MAX_CHAINE] = "";
    unsigned char LgChaine = 0;
    unsigned char Latent[MAX_CHAINE] = "";     /* code latent      */
    unsigned char LgLatent = 0;
    unsigned char Tempo[MAX_CHAINE];
    unsigned char LgTempo = 0;
    int         Rang;    /* rang dans le dico de la chaine cherch‚e */
    unsigned char ch[2];
    unsigned char l = 0;

    while ( ( Rang = Recevoir_Rang (FSource)) != 256)
    {
	if ( Rang == 257)    /* remise a zero du dico */
	{
	   Init_Dico ( Dico);
	   LgLatent = 0;
	   LgChaine = 0;
	}
	else
	  if ( LgLatent == 0)
	  {
	   *Latent  = (unsigned char) Rang;
	   LgLatent = 1;
	   *ch    = *Latent;
	   Ecrire_Fichier (FCible, ch, 1, false);
	  }
	  else
	   if ( Rang < 256)
	   {
	       *ch    = (unsigned char) Rang;
	       Ecrire_Fichier ( FCible, ch, 1, false);

	       /* copie d'une chaine dans une autre */
	       for ( l=0; l < LgLatent; l++) *(Chaine+l) = *(Latent+l);
	       LgChaine = LgLatent;

	       /* concatenation */
		*(Chaine+LgChaine++) = *ch;

	       Modifier_Dico ( Chaine, LgChaine, Dico);

	       *Latent = *ch;
	       LgLatent = 1;
	    }
	    else
	    {
	       /* copie d'une chaine dans une autre */
	       LgChaine = (Dico+Rang-258)->Lg;
	       for ( l=0; l < LgChaine; l++)
		  *(Chaine+l) = (Dico+Rang-258)->Chaine[l];

	       Ecrire_Fichier (FCible, Chaine, LgChaine, false);

	       /* copie d'une chaine dans une autre */
	       for ( l=0; l < LgLatent; l++) *(Tempo+l) = *(Latent+l);
	       LgTempo = LgLatent;
	       *ch = *Chaine;
	       *(Tempo+LgTempo++) = *ch;

	       Modifier_Dico ( Tempo, LgTempo, Dico);

	       /* copie d'une chaine dans une autre */
	       for ( l=0; l < LgChaine; l++) *(Latent+l) = *(Chaine+l);
	       LgLatent = LgChaine;
	    }

     } /* fin du while */
Ecrire_Fichier ( FCible, Chaine, LgChaine, true);
}


int DeCompression_LZW (char *chaine1,char *chaine2)
//--------------------------------------------------------------------------------
// DeCompression_LZW : Traitement de la decompression en utilisant la methode LZW
//--------------------------------------------------------------------------------
{
FILE *FSource, *FCible;          /* declaration des fichiers */
FSource=fopen(chaine1,"rb");     /* ouverture en lecture */
if (FSource==NULL) return(1);
FCible=fopen(chaine2,"wb");      /* ouverture en lecture */
if (FCible==NULL) return(2);
// Initilisation du dictionnaire
Init_Dico((T_Table *) &Dico);
// Compression de donnees proprement dite
DeCompresse_Donnees(FSource,FCible,(T_Table *) &Dico);
return(0);
}





// HUFFMAN




/* -------------------------------------------------- */
/* MAZ_Table  : mise … zero de la table servant …     */
/* =========    cumuler les frequences des caracteres */
/*--------------------------------------------------- */
void MAZ_Table(T_ASCII *Ptr_Ascii)
{
int i;
for( i = 0; i <= TAILLE_ASCII ; i++) {
  (Ptr_Ascii+i)->Cumul = 0;
  (Ptr_Ascii+i)->Donnee.U_Feuille.Data = i;
  (Ptr_Ascii+i)->Codifie = false;
  (Ptr_Ascii+i)->Donnee.Noeud = false;
  strcpy ( (Ptr_Ascii+i)->Code, "");
  }
}


/* -------------------------------------------------- */
/* Swap : Permute 2 cellules de la table ASCII.       */
/* ====                                               */
/*--------------------------------------------------- */
void Swap(T_ASCII *a,T_ASCII *b)
{
T_ASCII temp;
temp=*a;
*a=*b;
*b=temp;
}

/* -------------------------------------------------- */
/* TriTable : Trie la table ASCII des frequences par  */
/* ========   ordre decroissant.                      */
/*--------------------------------------------------- */
void TriTable(T_ASCII *Ptr_Ascii)
{
T_Bool Permut = true;
unsigned char Debut = 0;
unsigned char LastPermut = Debut;
int i;
while(Permut) {
  for( Permut=false, i=TAILLE_ASCII; i > Debut; i--)
    if ((Ptr_Ascii+i)->Cumul > (Ptr_Ascii+i-1)->Cumul) {
      Swap((Ptr_Ascii+i),(Ptr_Ascii+i-1));
      Permut=true;
      LastPermut=(unsigned char) i;
      }
  Debut=LastPermut;
  }
}


/* -------------------------------------------------- */
/* CalculFrequence : Cumul des frequences d'apparition */
/* ===============   des caracteres du fichier source */
/*--------------------------------------------------- */
void CalculFrequence(FILE *f,T_ASCII *Ptr_Ascii)
{
int NbreCaract;
int i;
unsigned char Buffer[BUFSIZ];
MAZ_Table(Ptr_Ascii);
do {
  NbreCaract = fread(Buffer, 1, BUFSIZ, f);
  if (NbreCaract > 0) {
    for(i = 0; i < NbreCaract; i++) {
      if (!((Ptr_Ascii+Buffer[i])->Cumul)) DimAscii++;
      (Ptr_Ascii+Buffer[i])->Cumul ++;
      }
    TotalOctet += NbreCaract;
    }
  }
while (NbreCaract>0);
TriTable(Ptr_Ascii);
}

/* ------------------------------------------------------ */
/* Creation_Arbre : Construction de l'arbre pour elaborer */
/* ==============   les codes.				  */
/*------------------------------------------------------- */
int Creation_Arbre(T_ASCII *Ptr_Ascii)
{
T_ASCII Temp;                /* variable temporaire */
int i, j, ind;
T_Bool Insertion;
/* creation de l'arbre permettant d'elaborer les codes */
for ( i = DimAscii-1; i > 0; i--) {
  if ((PtrNoeud=((T_Noeud *) malloc(sizeof(T_Noeud))))==NULL) return(3);
  /* mise a jour de la partie droite : cad la plus petite frequence */
  PtrNoeud->FDroite = (Ptr_Ascii+i)->Donnee;
  /* mise a jour de la partie gauche : cad la 2e frequence */
  PtrNoeud->FGauche = (Ptr_Ascii+i-1)->Donnee;
  /* calcul du cumul des donnees */
  Temp.Cumul = (Ptr_Ascii+i)->Cumul + (Ptr_Ascii+i-1)->Cumul;
  Temp.Donnee.Noeud = true;   /* c'est un noeud et non une feuille */
  Temp.Donnee.U_Feuille.Ptr = PtrNoeud;
  /* reclassement du noeud dans la table */
  for (j=i, Insertion=false; (j>0) && (!(Insertion)); j--)
    if ((Ptr_Ascii+j-1)->Cumul < Temp.Cumul)
      *(Ptr_Ascii+j) = *(Ptr_Ascii+j-1);
    else {
      Insertion = true;
      ind = j;
      }
    if (!(Insertion)) ind=0;
    *(Ptr_Ascii+ind)=Temp;
  }
Racine = PtrNoeud;
return(0);
}

/* ----------------------------------------------------- */
/* Creation_Codage : Parcours de l'arbre, et elaboration */
/* ===============   du codage. Module recursif.         */
/*------------------------------------------------------ */
void Creation_Codage(T_ASCII *Ptr_Ascii,T_Noeud *Ptr)
{
char code[MAXCODE];
/* exploration de la partie droite du pointeur */
strcpy(code,Ptr->CodeNoeud);
strcat(code, "1");
if ((Ptr->FDroite).Noeud) {
  strcpy((Ptr->FDroite).U_Feuille.Ptr->CodeNoeud,code);
  Creation_Codage(Ptr_Ascii, (Ptr->FDroite).U_Feuille.Ptr);
  }
else
  {
  strcpy((Ptr_Ascii+(Ptr->FDroite).U_Feuille.Data)->Code, code);
  (Ptr_Ascii+(Ptr->FDroite).U_Feuille.Data)->Codifie = true;
  }
/* exploration de la partie gauche du pointeur */
strcpy(code,Ptr->CodeNoeud);
strcat(code,"0");
if ((Ptr->FGauche).Noeud)
  {
  strcpy(((Ptr->FGauche).U_Feuille.Ptr)->CodeNoeud, code);
  Creation_Codage(Ptr_Ascii, (Ptr->FGauche).U_Feuille.Ptr);
  }
else
  {
  strcpy((Ptr_Ascii+(Ptr->FGauche).U_Feuille.Data)->Code, code);
  (Ptr_Ascii+(Ptr->FGauche).U_Feuille.Data)->Codifie = true;
  }
}


/* --------------------------------------------------- */
/* Ecriture_Table : Ecriture de la table de correspon- */
/* ==============   dance dans le fichier cible.       */
/*---------------------------------------------------- */
void Ecriture_Table(FILE *f,T_ASCII *Ptr_Ascii)
{
   unsigned char Bit_A_1[8] = {128, 64, 32, 16, 8, 4, 2, 1};

   int i, j;
   unsigned char *Ptr_Code;  /* table interm‚diaire avant ecriture */
   int Cpt_Car = 0;          /* compteur de caracteres pour Ptr_Code */
   unsigned char Octet;
   unsigned char Cpt;               /* compteur de bits positionnes */
   char NbOctet = 0;

   /* on ecrit d'abord le nombre de caracteres */
   /* envoyer dans la table                    */
   fwrite(&DimAscii, sizeof(int), 1, f);

   /* reservation de la place memoire pour ecrire la table de codage */
   /* surdimensionnement avec 4 octets par caractere code.           */
   Ptr_Code=(unsigned char *) malloc(DimAscii<<2);

   /* envoi de chaque caractere sur 3 octets :                   */
   /*   - le 1er etant le caractere a convertir,                 */
   /*   - LONGCODE bits du 2e : nombre de bits utiles pour le    */
   /*                           codage (maximum 16 bits),        */
   /*   - 8-LONGCODE bits du 2e + eventuellement 3e octet+etc..  */
   /*                         : codage du caractere.             */
   for(i = 0; i<=TAILLE_ASCII;i++)
     if ((Ptr_Ascii+i)->Codifie==true) {
       /* mise en table du caractere a coder */
	*(Ptr_Code+Cpt_Car) = (unsigned char) i;

       /* mise en table de la longueur du codage en DCB */
	Octet = strlen((Ptr_Ascii+i)->Code);
	Octet <<= (8-LONGCODE);          /* decalage de 4 positions */
	Cpt = LONGCODE;
	NbOctet = 1;       /* nombre d'octets servant a la codification */

	for (j=0; j<(int) strlen((Ptr_Ascii+i)->Code); j++)
	{
	    if (Cpt == 8)
	    {
	       *(Ptr_Code+Cpt_Car+NbOctet++) = Octet;
	       Octet  = Cpt = 0;
	    }
	    if ((Ptr_Ascii+i)->Code[j] == '1')
	    {
	       Octet |= Bit_A_1[Cpt];
	    }
	    Cpt++;
	}
	*(Ptr_Code+Cpt_Car+NbOctet) = Octet;
	Cpt_Car += NbOctet+1;
     }

    /* ecriture de toute la table */
     fwrite(&Cpt_Car, sizeof(Cpt_Car), 1, f);
     fwrite(Ptr_Code, 1, Cpt_Car, f);
     free(Ptr_Code);             /* liberation de la place memoire */

    /* ecriture du nombre total d'octets */
     fwrite(&TotalOctet, sizeof(TotalOctet), 1, f);
}

/* ----------------------------------------------------- */
/* Compressse_Donnees : Ecriture des donnees caractere   */
/* ==================   par caractere dans le fichier.   */
/*------------------------------------------------------ */
void Compresse_Donnees_HUF(FILE *FSource,FILE *FCible,T_ASCII *Ptr_Ascii)
{
    int NbreCaract;
    int i, l;
    unsigned char Octet = 0, Cpt = 0;
    unsigned char Bit_A_1[8] = {128, 64, 32, 16, 8, 4, 2, 1};
    int C_A_Ecrire = 0;

    fseek(FSource, 0L, SEEK_SET);/* repositionnement en debut de fichier */
    do
    {
      /* lecture en bloc des donnees */
       NbreCaract = fread(Buffer_Lect, 1, BUFSIZ, FSource);
       if (NbreCaract > 0)
       {
	 for(i = 0; i < NbreCaract; i++)
	 {
	     for (l = 0; l<(int) strlen((Ptr_Ascii+Buffer_Lect[i])->Code);l++)
	     {
		if ((Ptr_Ascii+Buffer_Lect[i])->Code[l] == '1')
		      Octet |= Bit_A_1[Cpt];
		Cpt++;
		if (Cpt == 8)
		{
		   Buffer_Ecri[C_A_Ecrire++] = Octet;
		   Octet = Cpt = 0;
		   if (C_A_Ecrire == BUFSIZ)
		   {
		       fwrite(Buffer_Ecri, 1, BUFSIZ, FCible);
		       C_A_Ecrire = 0;
		   }
		}
	     }
	 }
       }
    }
    while (NbreCaract > 0);

/* ecriture de la fin du buffer */
Buffer_Ecri[C_A_Ecrire++]=Octet;    /* sauvegarde du dernier octet */
fwrite(Buffer_Ecri, 1, C_A_Ecrire, FCible);
}


/* --------------------------------------------------- */
/* Compression_Huffman : Mise en place de l'algorithme */
/* ===================   de compression de Huffman.    */
/*---------------------------------------------------- */
int Compression_Huffman(char *chaine1,char *chaine2)
{
int i;
FILE *fSource, *fCible;          /* declaration des fichiers         */
fSource = fopen(chaine1,"rb");       /* ouverture en lecture */
if (fSource == NULL) return(1);
fCible = fopen(chaine2,"wb");       /* ouverture en lecture */
if (fCible == NULL) return(2);

/* lecture fichier source et calcul des frequences d'apparition */
CalculFrequence(fSource, ASCII);
/* creation de l'arbre */
i=Creation_Arbre(ASCII);
if (i) return(i);
/* lecture de l'arbre => creation du codage */
strcpy(Racine->CodeNoeud,"");
Creation_Codage(ASCII, Racine);
/* ecriture de la table de correspondance dans le fichier */
Ecriture_Table(fCible, ASCII);
/* ecriture des donnees dans le fichier cible */
Compresse_Donnees_HUF(fSource, fCible, ASCII);
return(0);
}



/* ----------------------------------------------------- */
/* Creer_Arbre_Decodage : Reconstitution de l'arbre pour */
/* ====================   decoder les donnees.           */
/*------------------------------------------------------ */
int Creer_Arbre_Decodage(FILE *FSource)
{
    unsigned char *Ptr_Code;  /* table intermediaire avant ecriture */
    int Cpt_Car = 0;          /* compteur de caracteres pour Ptr_Code */
    int Max_Car;              /* maximum de car. dans la table        */
    char Bit_A_1[8] = {(char) 128, 64, 32, 16, 8, 4, 2, 1};
    char Code[MAXCODE], Nb;
    char Cpt, l;              /* nombre de bits formant le code */
    unsigned char Octet, NbBit;
    T_Noeud *Ptr, *p;
    char NbOctet = 0;         /* nombre d'octets a lire pour le decodage */

   /* initialisation de la racine de l'arbre */
    if ((Racine=(T_Noeud *) malloc(sizeof(T_Noeud)))==NULL) return(3);
    Racine->FDroite.U_Feuille.Ptr = NULL;
    Racine->FGauche.U_Feuille.Ptr = NULL;

   /* lecture du nombre de caracteres du fichier initial a reconstituer */
    fread(&DimAscii, sizeof(DimAscii), 1, FSource);

   /* lecture du nombre de caracteres de la table de conversion */
    fread(&Cpt_Car, sizeof(Cpt_Car), 1, FSource);
    if ((Ptr_Code=(unsigned char *) malloc(Cpt_Car))==NULL) return(3);
    fread(Ptr_Code, 1, Cpt_Car, FSource);
    Max_Car = Cpt_Car;
    Cpt_Car = 0;

    for (Nb = 0; (Nb < DimAscii) && (Cpt_Car < Max_Car); Nb++)
    {
       Octet = *(Ptr_Code+Cpt_Car+1);
       NbBit = Octet >> (8-LONGCODE);               /* longueur du codage */
       Cpt = LONGCODE;
       NbOctet = 1;
       strcpy(Code, "");          /* initialisation de la chaine */

      /* reconstitution de la chaine de codage */
       for(l = 0; l<NbBit; l++)
       {
	  if (Cpt == 8)
	  {
	      Octet = *(Ptr_Code+Cpt_Car+(++NbOctet));
	      Cpt = 0;
	  }
	  if (Octet & Bit_A_1[(int) Cpt]) {
	  		strcat(Code,"1");
	  	}
	  else strcat(Code,"0");
	  Cpt++;
       }
       Ptr = Racine;

       for (l = 0; l < NbBit; l++)
       {
	/* creation d'une feuille droite */
	 if (Code[(int) l] == '1')
	  /* dernier bit a coder, il faut y mettre la feuille */
	   if (l == NbBit-1)
	   {
	      Ptr->FDroite.U_Feuille.Data = *(Ptr_Code+Cpt_Car);
	      Ptr->FDroite.Noeud = false;
	   }
	   else {
	   /* c'est encore un noeud */
	     if ((Ptr->FDroite).U_Feuille.Ptr == NULL) /* noeud inexistant */
	     {
		if ((p=(T_Noeud *) malloc(sizeof(T_Noeud)))==NULL) return(3);
		Ptr->FDroite.U_Feuille.Ptr = p;   /* lien avec fils droit */
		Ptr->FDroite.Noeud = true;
		p->FDroite.U_Feuille.Ptr = NULL;
		p->FGauche.U_Feuille.Ptr = NULL;
		Ptr = p;
	      }
	      else Ptr = Ptr->FDroite.U_Feuille.Ptr;
	   }

	/* creation d'une feuille gauche */
	 else
	  /* dernier bit a coder, il faut y mettre la feuille */
	   if (l==NbBit-1)
	   {
	      Ptr->FGauche.U_Feuille.Data = *(Ptr_Code+Cpt_Car);
	      Ptr->FGauche.Noeud = false;
	   }
	   else {
	   /* c'est encore un noeud */
	     if ((Ptr->FGauche).U_Feuille.Ptr == NULL) /* noeud inexistant */
	     {
		if ((p=(T_Noeud *) malloc(sizeof(T_Noeud)))==NULL) return(3);
		Ptr->FGauche.U_Feuille.Ptr = p;   /* lien avec fils gauche */
		Ptr->FGauche.Noeud = true;
		p->FDroite.U_Feuille.Ptr = NULL;
		p->FGauche.U_Feuille.Ptr = NULL;
		Ptr = p;
	     }
	     else Ptr = Ptr->FGauche.U_Feuille.Ptr;
	   }
	}
	Cpt_Car+=NbOctet;++Cpt_Car;
    }
free(Ptr_Code);     /* liberation de la place memoire */
/* lecture du nombre total d'octets compresses */
fread(&TotalOctet, sizeof(TotalOctet), 1, FSource);
return(0);
}


/* ----------------------------------------------------- */
/* Decodage_Donnees : Decompresse les donn‚es en parcou- */
/* ================   rant l'arbre.                      */
/*------------------------------------------------------ */
void Decodage_Donnees(FILE *FSource,FILE *FCible)
{
    char Bit_A_1[8] = {(char) 128, 64, 32, 16, 8, 4, 2, 1};
    int NbreCaract, i, C_A_Ecrire = 0;
    char Cpt = 0;
    T_Noeud *Ptr;
    T_Bool FinDecomp = false;

    Ptr = Racine;

    do
    {
      /* lecture en bloc des donnees */
       NbreCaract=fread(Buffer_Lect, 1, BUFSIZ, FSource);
       if (NbreCaract > 0)

       /* pour tous les caracteres du buffer */
	for(i = 0; i < NbreCaract; i++)

	/* pour tous les bits de chaque caractere */
	 for(Cpt = 0; Cpt < 8; Cpt++)
	 {
	   /* s'il y a mathematiquement d'autres octets */
	    if (FinDecomp) continue;

	   /* test si feuille droite */
	    if (Buffer_Lect[i] & Bit_A_1[(int) Cpt])

	      /* si c'est un pointeur sur un autre noeud */
		if ((Ptr->FDroite).Noeud) { Ptr = (Ptr->FDroite).U_Feuille.Ptr; }

	      /* c'est une feuille terminale donc un caractere */
		else
		{
		  /* ecriture des donn‚es par bloc */
		   Buffer_Ecri[C_A_Ecrire++] = (Ptr->FDroite).U_Feuille.Data;
		   if (C_A_Ecrire == BUFSIZ)
		   {
		       fwrite(Buffer_Ecri, BUFSIZ, 1, FCible);
		       C_A_Ecrire = 0;
		   }
		   if (!(--TotalOctet)) FinDecomp = true;
		   Ptr = Racine;
		}

	    /* test si feuille gauche */
	     else
	      /* si c'est un pointeur sur un autre noeud */
		if ((Ptr->FGauche).Noeud) Ptr = (Ptr->FGauche).U_Feuille.Ptr;

	      /* c'est une feuille terminale donc un caractere */
		else
		{
		  /* ecrire des donn‚es par bloc */
		   Buffer_Ecri[C_A_Ecrire++] = (Ptr->FGauche).U_Feuille.Data;
		   if (C_A_Ecrire == BUFSIZ)
		   {
		       fwrite(Buffer_Ecri, 1, BUFSIZ, FCible);
		       C_A_Ecrire = 0;
		   }
		   if (!(--TotalOctet)) FinDecomp = true;
		   Ptr = Racine;
		}
	 }
    }
    while (NbreCaract > 0);
    if (C_A_Ecrire) fwrite(Buffer_Ecri, 1, C_A_Ecrire, FCible);
}


/* ----------------------------------------------------- */
/* DeCompression_Huffman : Mise en place de l'algorithme */
/* =====================   de decompression de Huffman.  */
/*------------------------------------------------------ */
int DeCompression_Huffman(char *chaine1,char *chaine2)
{
FILE *FSource, *FCible;          /* declaration des fichiers         */
FSource = fopen(chaine1,"rb");       /* ouverture en lecture */
if (FSource == NULL) return(1);
FCible = fopen(chaine2,"wb");       /* ouverture en lecture */
if (FCible == NULL) return(2);
/* creation d'un arbre qui permettra en le parcourant de */
/* decoder les caracteres un … un.                        */
Creer_Arbre_Decodage(FSource);
/* decodage de chaque caractere */
Decodage_Donnees(FSource, FCible);
return(0);
}
