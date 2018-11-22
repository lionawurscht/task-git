# Maintainer: Lion Waaser <extra.lion.w@gmail.com>
pkgname=task-git-git
pkgver=869581d
pkgrel=1
pkgdesc="Backup Taskwarrior database to a git repository"
arch=(any)
url="https://github.com/lionawurscht/task-git"
license=('GPL')
groups=()
depends=('git' 'task')
makedepends=()
source=("git+https://github.com/lionawurscht/task-git")
md5sums=('SKIP')

pkgver() {
  cd "task-git"
  git describe --long --always | sed 's/\([^-]*-g\)/r\1/;s/-/./g'
}

package() {
	cd "${srcdir}/task-git"

    mkdir -p "${pkgdir}/usr/bin"
    mkdir -p "${pkgdir}/usr/share/doc/${pkgname}"
    mkdir -p "${pkgdir}/usr/share/licenses/${pkgname}"

    install -Tm 0755 task-git.sh "${pkgdir}/usr/bin/task-git"
    install -m 0444 README.md "${pkgdir}/usr/share/doc/${pkgname}/"
    install -m 0444 LICENSE.txt "${pkgdir}/usr/share/licenses/${pkgname}/"
}
