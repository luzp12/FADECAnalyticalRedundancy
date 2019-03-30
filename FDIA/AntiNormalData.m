function [M]=AntiNormalData(NM,minM,maxM)
M=(NM-0.5).*(maxM-minM)+minM;