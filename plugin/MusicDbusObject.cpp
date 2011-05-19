#include <QtCore/QTime>
#include <QtDeclarative/qdeclarative.h>

#include "MusicDbusObject.h"
#include "music_adaptor_p.h"

MusicDbusObject::MusicDbusObject(QObject *parent):
        QObject(parent)
{
    theCurrentTrack = 0;
    theNumberOfTracks = 0;
    thePlaybackMode = 0;
    thePlaybackState = 0;
    thePosition = 0;
    theVolume = 0;
    theMuted = false;
    m_nowNextTracks << "" << "" << "";
    m_state = "stopped";

    new MusicAdaptor(this);
    QDBusConnection::sessionBus().registerObject("/com/meego/app/music", this);
    QDBusConnection::sessionBus().registerService("com.meego.app.music");
}

// BEGIN Property function

QString MusicDbusObject::state()
{
    return m_state;
}

void MusicDbusObject::setState(QString &state)
{
    m_state = state;
    emit stateChanged();
}

QStringList MusicDbusObject::nowNextTracks()
{
    return m_nowNextTracks;
}

void MusicDbusObject::setNowNextTracks(QStringList &nowNextTracks)
{
    m_nowNextTracks = nowNextTracks;
    emit nowNextTracksChanged();
}

int MusicDbusObject::getCurrentTrack() {
    return theCurrentTrack;
}

void MusicDbusObject::setCurrentTrack(int track) {       // helper for property setting
    if (theCurrentTrack != track)
    {
        theCurrentTrack = track;
        emit trackChanged(track);
    }
}

int MusicDbusObject::getNumberOfTracks() {
    return theNumberOfTracks;
}

void MusicDbusObject::setNumberOfTracks(int numOfTracks) {       // helper for property setting
    if (theNumberOfTracks != numOfTracks)
    {
        theNumberOfTracks = numOfTracks;
        emit numberOfTracksChanged(numOfTracks);
    }
}

int MusicDbusObject::getPlaybackMode() {
    return thePlaybackMode;
}

void MusicDbusObject::setPlaybackMode(int mode) {       // helper for property setting
    if (thePlaybackMode != mode)
    {
        thePlaybackMode = mode;
        emit playbackModeChanged(mode);
    }
}

int MusicDbusObject::getPlaybackState() {
    return thePlaybackState;
}

void MusicDbusObject::setPlaybackState(int state) {       // helper for property setting
    if (thePlaybackState != state)
    {
        thePlaybackState = state;
        emit playbackStateChanged(state);
    }
}

int MusicDbusObject::getPosition() {
    return thePosition;
}

void MusicDbusObject::setPosition(int position) {       // helper for property setting
    if (thePosition != position)
    {
        thePosition = position;
        emit positionChanged(position);
    }
}

int MusicDbusObject::getVolume() {
    return theVolume;
}

void MusicDbusObject::setVolume(int level) {
    if (theVolume != level)
    {
        theVolume = level;
        emit volumeChanged(level);
    }
}

bool MusicDbusObject::muted() {                    // helper for property setting
    return theMuted;
}

void MusicDbusObject::setMuted(bool muted) {
    if (theMuted != muted)
    {
        theMuted = muted;
        emit mutedChanged(muted);
    }
}

void MusicDbusObject::setError(int errorCode) {
    emit error(errorCode);
}

void MusicDbusObject::setPlayerClosed() {
    emit playerClosed();
}

void MusicDbusObject::setPlayerLaunched() {
    emit playerLaunched();
}

QML_DECLARE_TYPE(MusicDbusObject);
