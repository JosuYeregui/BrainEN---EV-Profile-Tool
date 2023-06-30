clc
clearvars
close all

BCN = readtable("BCN_AMB_EV_Info.csv");
BCN.Max_Charge_P = zeros(height(BCN), 1);
DefaultEV = readtable("Default_EV.csv");

%%

for i = 1:height(BCN)
    target = BCN(i,:).Model{1};
%     if contains(target, "TESLA")
%         target = strrep(target, "TESLA", "TESLA MODEL");
%     end
    a = cellfun(@(c)wfEdits(c,target),upper(DefaultEV.Model));
    [b, c] = min(a);
    paired =DefaultEV.Model{c};

    BCN.Max_Charge_P(i) = DefaultEV.Max_Charge_P(c);
    if target == "TESLA S"
        BCN.Max_Charge_P(i) = 100;
    end
    disp(target + "        " + paired + "      " + BCN.Max_Charge_P(i))
end

writetable(BCN, "BCN_AMB_EV_Info_wP.csv")

function d = wfEdits(S1,S2)
% Wagner–Fischer algorithm to calculate the edit distance / Levenshtein distance.
%
N1 = 1+numel(S1);
N2 = 1+numel(S2);
%
D = zeros(N1,N2);
D(:,1) = 0:N1-1;
D(1,:) = 0:N2-1;
%
for r = 2:N1
  for c = 2:N2
    D(r,c) = min([D(r-1,c)+1, D(r,c-1)+1, D(r-1,c-1)+~strcmpi(S1(r-1),S2(c-1))]);
  end
end
d = D(end);
%
end