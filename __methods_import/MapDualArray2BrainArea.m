function brain_area = MapDualArray2BrainArea(x,y) 
brain_area = char((y<=48)*x{1} + (y>48)*x{2});