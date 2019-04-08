function settick(axis,ticks)
n=length(ticks);
tkx=1:8;tky=get(gca,'YTick');
switch axis
    case 'x'
        w=linspace(tkx(1),tkx(end),n);
        set(gca, 'XTick', w, 'XTickLabel', []);%刷新刻度，去掉刻度值
        yh=-0.002;%按坐标轴比例调整刻度纵坐标位置
        for i=1:n
            text('Interpreter','tex','String',ticks(i),'Position',[w(i),yh],'horizontalAlignment', 'center');
        end
    case 'y'
        w=linspace(tky(1),tky(end),n);
        set(gca, 'YTick', w, 'YTickLabel', []);
        xh=(11*w(1)-w(end))/10;
        for i=1:n
            text('Interpreter','tex','String',ticks(i),'Position',[xh,w(i)],'horizontalAlignment', 'center');
        end
end