function NPP =mats(NPP0, beta, B1, B2)
NPP = NPP0 * (1 + beta *log(B1/B2));
end