%% agent that per subscribed url

-module(agent).
-export(start/1, start_link/1, cancel/1).
-record(state, {server, url=""}).


loop(S = #state{server=Server}) ->
    receive
        {Server, Ref, cancel} ->
            Server ! {Ref, ok};
        {Server, Ref, _} ->
            Server ! {Ref, [S|Ref},
            loop(S#state{server=Server})
    end.

