[phi, psi] = wavefun('coif2', 3);
d1 = 0; d2 = 0;
for a=1:12
  for b=1:12
    for c=1:12
      d1 = d1+ (cphi(a,b,c) - phi(a)*phi(b)*phi(c))^2;
      d2 = d2+ (cpsi(a,b,c) - psi(a)*psi(b)*psi(c))^2;
    end
  end
end
d1 = sqrt(d1)
d2 = sqrt(d2)
