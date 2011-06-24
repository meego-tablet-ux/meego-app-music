/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

Item {
    id: content

    // control parameters
    property int page: -1
    property string uri: ""
    property int position: -1
    property string command: ""
    property bool shuffle: false
    property bool repeat: false
    property string artist: ""
    property string album: ""
    property string playlist: ""

    /* page definitions:
       0 = playqueue
       1 = playlists
       2 = favorites
       3 = artists
       4 = albums
       5 = all tracks
       6 = artist detail
       7 = album detail
       8 = playlist detail
    */

    // status paramaters
    property string urn: ""
    signal prevPressed();
    signal nextPressed();
    signal sliderMoved(int position);

    function clear()
    {
        page = -1;
        uri = "";
        position = -1;
        command = "";
        shuffle = false;
        repeat = false;
        artist = "";
        album = "";
        playlist = "";
    }

    function set(n_page, n_command, n_uri, n_position, m_shuffle, m_repeat, m_artist, m_album, m_playlist)
    {
        page = n_page;
        command = n_command;
        uri = n_uri;
        position = n_position;
        shuffle = m_shuffle;
        repeat = m_repeat;
        artist = m_artist;
        album = m_album;
        playlist = m_playlist;
    }
}
