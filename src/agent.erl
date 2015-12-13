%% agent that per subscribed url

-module(agent).

-export([sub/1, sub_link/1, init/2, cancel/1, refresh/1]).
-record(state, {server, url=""}).

%%% Public interface
sub(Url) ->
    spawn(?MODULE, init, [self(), Url]).

sub_link(Url) ->
    spawn_link(?MODULE, init, [self(), Url]).

%% Wrapper for loop
init(Server, Url) ->
    loop(#state{server=Server,url=Url}).

%% cancel subscription
cancel(Pid) ->
    %% Monitor in case the process is already dead
    Ref = erlang:monitor(process, Pid),
    Pid ! {self(), Ref, cancel},
    receive
        {Ref, ok} ->
            erlang:demonitor(Ref, [flush]),
            ok;
        {'DOWN', Ref, process, Pid, _Reason} ->
            ok
    end.

%% update subscription
refresh(Pid) ->
    %% Monitor in case the process is already dead
    Ref = erlang:monitor(process, Pid),
    Pid ! {self(), Ref, update},
    receive
        {Ref, Content} ->
            erlang:demonitor(Ref, [flush]),
            {Ref, Content};
        {'DOWN', Ref, process, Pid, _Reason} ->
            ok
    end.

%% controls actions
loop(S = #state{server=Server}) ->
    receive
        {Server, Ref, cancel} ->
            Server ! {Ref, ok};
        {Server, Ref, update} ->
            Content = update(S#state.url),
            Server ! {Ref, Content},
            loop(S#state{server=Server});
        {Server, Ref, _} ->
            Server ! {Ref, io:format("No actions~n")},
            loop(S#state{server=Server})
    end.

%% sudo fetch url content
update(Url) ->
    "Sudo content for URL " ++ Url ++ " Updated~n".


