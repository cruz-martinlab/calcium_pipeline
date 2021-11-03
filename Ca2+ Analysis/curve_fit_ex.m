rsq = [];
for i = [2,20,21]
    x = 0:0.05:5;
    x = x';
    y = corr_curves(i).sel;
    [f,g] = fit(x,y,'exp2')
     plot(f,x,y)

    rsq(i) = g.rsquare;
    b= f.b;
    d =f.d;
    
    
end