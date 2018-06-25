#
# spec file for package obs-service-download_files
#
# Copyright (c) 2017 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


%define service download_files
Name:           obs-service-%{service}
Version:        0.6.0.git.1502884469.0993a01
Release:        0
Summary:        An OBS source service: download files
License:        GPL-2.0+
Group:          Development/Tools/Building
Url:            https://github.com/openSUSE/obs-service-%{service}
Source:         %{name}-%{version}.tar.gz
Requires:       build >= 2012.08.24
Requires:       diffutils
Requires:       wget
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description
This is a source service for openSUSE Build Service.

This service is parsing all spec files and downloads all Source files which are specified via a http, https or ftp url.

%prep
%setup -q

%build

%install
%makeinstall

%pre
%{_sbindir}/groupadd -r obsrun 2> /dev/null || :
%{_sbindir}/useradd -r -s /bin/false -c "User for build service backend" -d %{_prefix}/lib/obs -g obsrun obsrun 2> /dev/null || :

%files
%defattr(-,root,root)
%doc README.md
%dir %{_prefix}/lib/obs
%{_prefix}/lib/obs/service
%dir %{_sysconfdir}/obs
%dir %{_sysconfdir}/obs/services
%config(noreplace) %{_sysconfdir}/obs/services/*
%dir %{_localstatedir}/cache/obs
%defattr(-,obsrun,obsrun)
%dir %{_localstatedir}/cache/obs/download_files
%dir %{_localstatedir}/cache/obs/download_files/file
%dir %{_localstatedir}/cache/obs/download_files/filename

%changelog
