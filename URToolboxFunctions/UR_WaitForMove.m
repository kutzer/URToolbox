function UR_WaitForMove(obj)
% UR_WAITFORMOVE pauses program execution until the hardware finishes
% moving.
%   UR_WAITFORMOVE(obj) pauses program execution until the hardware tied ot
%   the specified UR object completes a movement.
%
%   NOTE: This function requires an established URX connection with the
%   robot.
%
%   M. Kutzer, 14Mar2018, USNA

%% Check inputs
narginchk(1,1);

% TODO: Check to see if the input is a valid object from the UR class
% TODO: Check if the URX connection is established

%% Wait for movement
fprintf('Moving to position...');

X_all = [];
isMoving = true;
while isMoving
    TT = obj.TTRANS;
    H_cur = pTransform2mMatrix(TT);
    X_all(:,end+1) = H_cur(1:3,4);
    
    if size(X_all,2) > 1
        v = X_all(:,end) - X_all(:,end-1);
        d = norm(v);
    else
        d = inf;
    end
    
    if d < 1
        isMoving = false;
    end
    
    pause(0.05);
end
fprintf('COMPLETE\n');