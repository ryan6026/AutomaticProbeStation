% A move function for ASI stages that are 20 years old and have terrible accuracy
% This can be replaced with moveStage() for newer models
function moveStageLong(stage, x, y) % in mm
    dist=.2;
    for i=1:2
        moveStage(stage, x,y)
        pause(.2)
        moveStage(stage, x,y-dist)
        pause(.2)
        dist = (dist-.05);
        moveStage(stage, x,y+dist)
        pause(.2)
%         moveStage(stage, x,y)
        dist = (dist-.05);
    end
    moveStage(stage, x,y)
end
