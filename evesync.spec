%{!?RELEASE: %global RELEASE 1}
%{!?VERSION: %global VERSION 1.0.1}
%global debug_package %{nil}
%define check_gem_installed() (rpm -q rubygem-%{1} || echo '  Installing gem %{1}' && gem install %{1})
%define check_gem_installed_version() (rpm -q rubygem-%{1}-%{2} || echo '  Installing gem %{1}-%{2}' && gem install %{1} --version %{2})

Name: evesync
Version: %{VERSION}
Release: %{RELEASE}%{?dist}
Group: Applications/System
License: BSD-2-Clause
URL: http://mrexox.github.io
Source0: %{name}-%{version}.gem
Summary: Daemons and utility for package and file changes synchronization

Requires: ruby-devel
Requires: ruby(release)
Requires: ruby(rubygems)
Requires: rubygem(ffi)
# These packages are not yet provided for centos
# Requires: rubygem(full_dup)
# Requires: rubygem(hashdiff)
# Requires: rubygem(lmdb)
# Requires: rubygem(rb-inotify) = 0.9.9
# Requires: rubygem(toml-rb)
# Requires: rubygem(rubyzip)
# Requires: rubygem(net-ntp)

BuildRequires: epel-release
BuildRequires: rubygem(rake)
BuildRequires: rpm-build
BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: automake


%description
Daemons and utility for package and file changes synchronization.

%prep
rake build
cp %{name}-%{version}.gem %{_sourcedir}/%{name}-%{version}.gem
%setup -q -c -T

%install
gem install %{SOURCE0} \
    --ignore-dependencies \
    --install-dir %{buildroot}/usr/local/share/gems \
    --bindir %{buildroot}/%{_sbindir}

%clean
rake clean[0]

%post
%check_gem_installed full_dup
%check_gem_installed hashdiff
%check_gem_installed lmdb
%check_gem_installed_version rb-inotify 0.9.9
%check_gem_installed toml-rb
%check_gem_installed rubyzip
%check_gem_installed net-ntp



%files
/usr/local/share/gems/gems/%{name}-%{version}/
/usr/local/share/gems/cache/%{name}-%{version}.gem
/usr/local/share/gems/specifications/%{name}-%{version}.gemspec
%exclude /usr/local/share/gems/doc/
/usr/sbin/evesync
/usr/sbin/evesyncd
/usr/sbin/evedatad
/usr/sbin/evemond
/usr/sbin/evehand
