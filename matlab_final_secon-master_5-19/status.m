function status(pnlHandle, string)

status = findobj(pnlHandle.Children, 'Tag', 'status');
status.String = ['State: ' string];

end

