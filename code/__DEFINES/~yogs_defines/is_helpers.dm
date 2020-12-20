#define is_thrall(M) (istype(M, /mob/living) && M.mind?.has_antag_datum(/datum/antagonist/thrall))
#define is_shadow(M) (istype(M, /mob/living) && M.mind?.has_antag_datum(/datum/antagonist/shadowling))
#define is_shadow_or_thrall(M) (is_thrall(M) || is_shadow(M))

#define isdarkspawn(A) (A?.mind?.has_antag_datum(/datum/antagonist/darkspawn))
#define isveil(A) (A?.mind?.has_antag_datum(/datum/antagonist/veil))
#define is_darkspawn_or_veil(A) (A.mind && isdarkspawn(A) || isveil(A))

#define isspacepod(A) (istype(A, /obj/spacepod))
<<<<<<< HEAD

#define ispreternis(A) (is_species(A, /datum/species/preternis))

#define isandroid(A) (is_species(A, /datum/species/android))
=======
>>>>>>> 244ebfec5e5... Radstorms no longer mutate radimmune species (#10681)
