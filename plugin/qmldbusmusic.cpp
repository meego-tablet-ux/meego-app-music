/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "qmldbusmusic.h"

#include <QDebug>
#include <QDBusConnection>

QmlDBusMusic::QmlDBusMusic(QObject *parent) :
  QObject(parent)
{
  m_nowNextTracks << "" << "" << "";
  m_state = "stopped";
  new MusicDBusAdaptor(this);
  QDBusConnection::sessionBus().registerObject("/com/meego/app/music", this);
  QDBusConnection::sessionBus().registerService("com.meego.app.music");
}

QmlDBusMusic::~QmlDBusMusic()
{
}

QString QmlDBusMusic::state() const
{
  return m_state;
}

void QmlDBusMusic::setState(QString state)
{
  m_state = state;
  emit stateChanged();
}

QStringList QmlDBusMusic::nowNextTracks() const
{
  return m_nowNextTracks;
}

void QmlDBusMusic::setNowNextTracks(QStringList nowNextTracks)
{
  m_nowNextTracks = nowNextTracks;
  emit nowNextTracksChanged();
}

MusicDBusAdaptor::MusicDBusAdaptor(QmlDBusMusic *obj) : QDBusAbstractAdaptor(obj), m_QmlDBusMusic(obj)
{
  setAutoRelaySignals(true) ;
}

MusicDBusAdaptor::~MusicDBusAdaptor()
{

}

QString MusicDBusAdaptor::state() const
{
  return m_QmlDBusMusic->state();
}

void MusicDBusAdaptor::setState(QString state)
{
  m_QmlDBusMusic->setState(state);
}

QStringList MusicDBusAdaptor::nowNextTracks() const
{
  return m_QmlDBusMusic->nowNextTracks();
}

void MusicDBusAdaptor::setNowNextTracks(QStringList nowNextTracks)
{
  m_QmlDBusMusic->setNowNextTracks(nowNextTracks);
}

void MusicDBusAdaptor::next()
{
  emit m_QmlDBusMusic->next();
}

void MusicDBusAdaptor::prev()
{
  emit m_QmlDBusMusic->prev();
}

void MusicDBusAdaptor::play()
{
  emit m_QmlDBusMusic->play();
}

void MusicDBusAdaptor::pause()
{
  emit m_QmlDBusMusic->pause();
}
