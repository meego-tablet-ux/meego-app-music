#ifndef MUSICDBUSOBJECT_H
#define MUSICDBUSOBJECT_H

#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QTimer>
#include <QString>
#include <QStringList>

class MusicAdaptor;

class MusicDbusObject : public QObject
{
    Q_OBJECT
    Q_ENUMS(PLAYBACK_STATE);
    Q_ENUMS(PLAYBACK_MODE);
    Q_ENUMS(ERROR_CODE);

    Q_PROPERTY(int currentTrack READ getCurrentTrack WRITE setCurrentTrack NOTIFY trackChanged)
    Q_PROPERTY(int numberOfTracks READ getNumberOfTracks WRITE setNumberOfTracks NOTIFY numberOfTracksChanged)
    Q_PROPERTY(int playbackMode READ getPlaybackMode WRITE setPlaybackMode NOTIFY playbackModeChanged)
    Q_PROPERTY(int playbackState READ getPlaybackState WRITE setPlaybackState NOTIFY playbackStateChanged)
    Q_PROPERTY(int position READ getPosition WRITE setPosition NOTIFY positionChanged)
    Q_PROPERTY(int volume READ getVolume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(bool muted READ muted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(QString state READ state WRITE setState NOTIFY stateChanged)
    Q_PROPERTY(QStringList nowNextTracks READ nowNextTracks WRITE setNowNextTracks NOTIFY nowNextTracksChanged)

    friend class MusicAdaptor;

public:

    enum PLAYBACK_STATE { 
        PLAYBACK_STATE_UNKNOWN = 0,
        PLAYBACK_STATE_PLAY = 1,
        PLAYBACK_STATE_PAUSE = 2,
        PLAYBACK_STATE_STOP = 3,
        PLAYBACK_STATE_FASTFORWARD = 4,
        PLAYBACK_STATE_REWIND = 5
    };
    
    enum PLAYBACK_MODE { 
        PLAYBACK_MODE_NORMAL = 0,
        PLAYBACK_MODE_REPEATED = 1,
        PLAYBACK_MODE_SHUFFLE = 2
    };
    
    enum ERROR_CODE { 
        SHOW_PLAYER_FAILED = 0,
        CLOSE_PLAYER_FAILED,    // 1
        GET_CURRENT_TRACK_METADATA_FAILED, // 2
        GET_ALL_METADATA_FAILED,    // 3
        SEEK_BY_TIME_FAILED,    // 4
        SEEK_BY_TRACK_FAILED,   // 5
        GET_PLAYBACK_STATE_FAILED,  // 6
        GET_PLAYBACK_MODE_FAILED,   // 7
        SET_MUTED_FAILED,   // 8
        SET_VOLUME_FAILED,  // 9
        GET_VOLUME_FAILED,  // 10
        GET_POSITION_FAILED,    // 11
        GET_NUMBER_OF_TRACKS_FAILED,    // 12
        GET_CURRENT_TRACK_FAILED    // 13
    };    

    MusicDbusObject(QObject *parent = 0);

    Q_INVOKABLE void setError(int errorCode);
    Q_INVOKABLE void setPlayerClosed();
    Q_INVOKABLE void setPlayerLaunched();
    Q_INVOKABLE void setCurrentTrack(int track);
    Q_INVOKABLE void setNumberOfTracks(int numOfTracks);
    Q_INVOKABLE void setPlaybackMode(int mode);
    Q_INVOKABLE void setPlaybackState(int state);
    Q_INVOKABLE void setPosition(int position);
    Q_INVOKABLE bool muted();
    Q_INVOKABLE void setState(QString &state);
    Q_INVOKABLE void setNowNextTracks(QStringList &nowNextTracks);

public Q_SLOTS: // METHODS
    int getCurrentTrack();
    int getNumberOfTracks();
    int getPlaybackMode();
    int getPlaybackState();
    int getPosition();
    int getVolume();
    void setMuted(bool muted);
    void setVolume(int level);
    QString state();
    QStringList nowNextTracks();

signals:
    void positionChanged(int position);
    void trackChanged(int track);
    void stateChanged();
    void nowNextTracksChanged();
    void numberOfTracksChanged(int tracks);
    void playbackModeChanged(int mode);
    void playbackStateChanged(int state);
    void volumeChanged(int level);
    void mutedChanged(bool muted);
    void error(int errorCode);
    void playerClosed();
    void playerLaunched();

    void close();
    void fastForward();
    void pause();
    void play();
    void playNextTrack();
    void playPreviousTrack();
    void rewind();
    void show();
    void stop();

private:
    int theCurrentTrack;
    int theNumberOfTracks;
    int thePlaybackMode;
    int thePlaybackState;
    int thePosition;
    int theVolume;
    bool theMuted;
    QString m_state;
    QStringList m_nowNextTracks;

    Q_DISABLE_COPY(MusicDbusObject)
};

#endif // MUSICDBUSOBJECT_H
