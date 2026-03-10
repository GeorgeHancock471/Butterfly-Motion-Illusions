
g=1;
while(g)
    [~, ~, buttons] = GetMouse(window);
    
    if ~any(keyCode) & ~any(buttons)
    g=0;
    end

end

