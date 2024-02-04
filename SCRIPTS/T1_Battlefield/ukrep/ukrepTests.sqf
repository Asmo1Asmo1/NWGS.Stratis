NWG_UKREP_VectorMathTest = {
    //Determine if previous algorithm and new one give exact same results
    private _rootPos = [0.3428,0.1775,0.1693];
    private _curPos  = [0.8342,0.1346,0.7526];

    private _oldOffset = [
        ((_curPos#0)-(_rootPos#0)),
        ((_curPos#1)-(_rootPos#1)),
        ((_curPos#2)-(_rootPos#2))
    ];
    private _newOffset = _curPos vectorDiff _rootPos;

    private _oldPos = [
        ((_rootPos#0)+(_oldOffset#0)),
        ((_rootPos#1)+(_oldOffset#1)),
        ((_rootPos#2)+(_oldOffset#2))
    ];
    private _newPos = _rootPos vectorAdd _newOffset;

    //return
    [(_oldOffset isEqualTo _newOffset),(_oldPos isEqualTo _newPos)]
};