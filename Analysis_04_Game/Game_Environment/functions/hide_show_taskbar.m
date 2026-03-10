% Path to nircmd executable (change this to where you downloaded nircmd)
nircmdPath = fullfile('nircmd\nircmd.exe');

% Hide the taskbar
system([nircmdPath ' win hide class Shell_TrayWnd']);

%pause(3);
system([nircmdPath ' win show class Shell_TrayWnd']);
