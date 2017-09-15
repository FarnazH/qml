module fchl_utils

    implicit none

contains


pure function calc_angle(a, b, c) result(angle)

    implicit none

    double precision, intent(in), dimension(3) :: a
    double precision, intent(in), dimension(3) :: b
    double precision, intent(in), dimension(3) :: c

    double precision, dimension(3) :: v1
    double precision, dimension(3) :: v2

    double precision :: cos_angle
    double precision :: angle

    v1 = a - b
    v2 = c - b

    v1 = v1 / norm2(v1)
    v2 = v2 / norm2(v2)

    cos_angle = dot_product(v1,v2)

    ! Clipping
    if (cos_angle > 1.0d0) cos_angle = 1.0d0
    if (cos_angle < -1.0d0) cos_angle = -1.0d0

    angle = acos(cos_angle)
 
end function calc_angle


pure function calc_cos_angle(a, b, c) result(cos_angle)

    implicit none

    double precision, intent(in), dimension(3) :: a
    double precision, intent(in), dimension(3) :: b
    double precision, intent(in), dimension(3) :: c

    double precision, dimension(3) :: v1
    double precision, dimension(3) :: v2

    double precision :: cos_angle

    v1 = a - b
    v2 = c - b

    v1 = v1 / norm2(v1)
    v2 = v2 / norm2(v2)

    cos_angle = dot_product(v1,v2)

end function calc_cos_angle

pure function calc_cos_angle_vectors(v1, v2) result(cos_angle)

    implicit none
    double precision, dimension(3), intent(in) :: v1
    double precision, dimension(3), intent(in) :: v2

    double precision :: cos_angle

    cos_angle = dot_product(v1/norm2(v1),v2/norm2(v2))

end function calc_cos_angle_vectors

pure function calc_G(a, b, c, d, dihedral_power) result(G)

    implicit none

    double precision, intent(in), dimension(3) :: a
    double precision, intent(in), dimension(3) :: b
    double precision, intent(in), dimension(3) :: c
    double precision, intent(in), dimension(3) :: d
    double precision, intent(in) :: dihedral_power

    double precision :: G

    G = 3.0d0 / (norm2(a) * norm2(b) * norm2(c) * norm2(d))**(dihedral_power) * ( -4.0d0 + 3.0d0 &
        & * (calc_cos_angle_vectors(a,b)**2 + calc_cos_angle_vectors(a,c)**2 + calc_cos_angle_vectors(a,d)**2 &
        &  + calc_cos_angle_vectors(b,c)**2 + calc_cos_angle_vectors(b,d)**2 + calc_cos_angle_vectors(c,d)**2) &
        &  - 9.0d0 * (calc_cos_angle_vectors(b,c) * calc_cos_angle_vectors(c,d) * calc_cos_angle_vectors(d,b)  & 
        &           + calc_cos_angle_vectors(c,d) * calc_cos_angle_vectors(d,a) * calc_cos_angle_vectors(a,c)  &
        &           + calc_cos_angle_vectors(a,b) * calc_cos_angle_vectors(b,d) * calc_cos_angle_vectors(d,a)  &
        &           + calc_cos_angle_vectors(b,c) * calc_cos_angle_vectors(c,a) * calc_cos_angle_vectors(a,b)) &
        & + 27.0d0 * (calc_cos_angle_vectors(a,b) * calc_cos_angle_vectors(b,c) * calc_cos_angle_vectors(c,d)  &
        & * calc_cos_angle_vectors(d,a)))

end function calc_G

pure function calc_ksi4(Ai, Bi, Ci, Di, dihedral_power) result(ksi4)

    implicit none

    double precision, intent(in), dimension(3) :: Ai
    double precision, intent(in), dimension(3) :: Bi
    double precision, intent(in), dimension(3) :: Ci
    double precision, intent(in), dimension(3) :: Di
    double precision, intent(in) :: dihedral_power

    double precision, dimension(3) :: a
    double precision, dimension(3) :: b
    double precision, dimension(3) :: c
    double precision, dimension(3) :: d
    double precision, dimension(3) :: e
    double precision, dimension(3) :: f

    double precision :: ksi4

    a = Ci - Bi
    b = Ai - Ci
    c = Bi - Ai
    d = Ai - Di
    e = Bi - Di
    f = Ci - Di

    ksi4 = calc_G(c, a, f, d, dihedral_power) + calc_G(c, e, f, b, dihedral_power) + calc_G(b, a, e, d, dihedral_power)

end function

function print_ksi4(X, nneighbors) result(ksi)

    implicit none

    double precision, dimension(:,:), intent(in) :: X
    integer, intent(in) :: nneighbors

    double precision :: ksi

    double precision, parameter :: pi = 4.0d0 * atan(1.0d0)

    double precision :: cos_phi
    double precision::dihedral
    integer :: a, b, c

    do a = 2, nneighbors
        do b = 2, nneighbors
            if (b.eq.a) cycle
            do c = 2, nneighbors
                if ((c.eq.a).or.(c.eq.b)) cycle

                cos_phi= (cos(X(a+3,b)) - cos(X(a+3,c)) * cos(X(b+3,c))) &
                    & / (sin(X(a+3,c)) * sin(X(b+3,c)))

                dihedral = acos(cos_phi)

                ! write (*,*) a, b, c, acos(cos_phi) / pi * 180.0d0

            enddo
        enddo
    enddo

    ksi = 0.0d0

end function print_ksi4

pure function calc_ksi3(X, j, k, angular_power) result(ksi3)

    implicit none

    double precision, dimension(:,:), intent(in) :: X

    integer, intent(in) :: j
    integer, intent(in) :: k

    double precision, intent(in) :: angular_power

    double precision :: cos_i, cos_j, cos_k
    double precision :: di, dj, dk

    double precision :: ksi3

    cos_i = calc_cos_angle(x(3:5, k), x(3:5, 1), x(3:5, j))
    cos_j = calc_cos_angle(x(3:5, j), x(3:5, k), x(3:5, 1))
    cos_k = calc_cos_angle(x(3:5, 1), x(3:5, j), x(3:5, k))

    dk = x(1, j)
    dj = x(1, k)
    di = norm2(x(3:5, j) - x(3:5, k))

    ksi3 = (1.0d0 + 3.0d0 * cos_i*cos_j*cos_k) / (di * dj * dk)**(angular_power)

end function calc_ksi3

pure function cross_product(a, b) result(cross)

    implicit none

    double precision, intent(in), dimension(3) :: a
    double precision, intent(in), dimension(3) :: b

    double precision, dimension(3) :: cross

    cross(1) = a(2) * b(3) - a(3) * b(2)
    cross(2) = a(3) * b(1) - a(1) * b(3)
    cross(3) = a(1) * b(2) - a(2) * b(1)

end function cross_product

pure function calc_dihedral(a, b, c, d) result(dihedral)

    implicit none

    double precision, intent(in), dimension(3) :: a
    double precision, intent(in), dimension(3) :: b
    double precision, intent(in), dimension(3) :: c
    double precision, intent(in), dimension(3) :: d

    double precision, dimension(3) :: b1 
    double precision, dimension(3) :: b2
    double precision, dimension(3) :: b3
    
    double precision, dimension(3) :: x12
    double precision, dimension(3) :: x23
    
    double precision :: dihedral

    b1 = b - a 
    b2 = c - b
    b3 = d - c

    x12 = cross_product(b1, b2)
    x23 = cross_product(b2,b3)

    dihedral = atan2(dot_product(cross_product(x12, x23), b2/norm2(b2)), dot_product(x12, x23))

    ! hack to remove the sign for now 
    dihedral = acos(cos(dihedral))

end function calc_dihedral


pure function atomic_distl2(X1, X2, N1, N2, ksi1, ksi2, sin1, sin2, cos1, cos2, &
    & sin14, sin24, cos14, cos24, &
    & t_width, d_width, cut_distance, order, pd, ang_norm2, &
    & distance_scale, angular_scale, dihedral_scale) result(aadist)

    implicit none

    double precision, dimension(:,:), intent(in) :: X1
    double precision, dimension(:,:), intent(in) :: X2

    integer, intent(in) :: N1
    integer, intent(in) :: N2

    double precision, dimension(:), intent(in) :: ksi1
    double precision, dimension(:), intent(in) :: ksi2

    double precision, dimension(:,:,:), intent(in) :: sin1
    double precision, dimension(:,:,:), intent(in) :: sin2
    double precision, dimension(:,:,:), intent(in) :: cos1
    double precision, dimension(:,:,:), intent(in) :: cos2

    double precision, dimension(:,:,:,:), intent(in) :: sin14
    double precision, dimension(:,:,:,:), intent(in) :: sin24
    double precision, dimension(:,:,:,:), intent(in) :: cos14
    double precision, dimension(:,:,:,:), intent(in) :: cos24

    double precision, intent(in) :: t_width
    double precision, intent(in) :: d_width 
    double precision, intent(in) :: cut_distance
    integer, intent(in) :: order
    double precision, dimension(:,:), intent(in) :: pd
    double precision, intent(in) :: angular_scale
    double precision, intent(in) :: dihedral_scale
    double precision, intent(in) :: distance_scale

    double precision :: aadist

    double precision :: d

    integer :: m_1, m_2

    integer :: i, m, p11, p12, p21, p22

    double precision :: angular 
    double precision :: dihedral
    double precision :: maxgausdist2

    integer :: pmax1
    integer :: pmax2

    double precision :: inv_width
    double precision :: r2

    double precision, dimension(order) :: s
    
    double precision, parameter :: pi = 4.0d0 * atan(1.0d0)

    double precision :: g1 
    double precision :: a0 

    logical, allocatable, dimension(:) :: mask1
    logical, allocatable, dimension(:) :: mask2

    double precision :: sin1_temp, cos1_temp

    double precision :: ang_temp
    double precision :: dihedral_temp

    double precision, intent(in):: ang_norm2

    pmax1 = int(maxval(x1(2,:n1)))
    pmax2 = int(maxval(x2(2,:n2)))

    allocate(mask1(pmax1))
    allocate(mask2(pmax2))
    mask1 = .true.
    mask2 = .true.

    do i = 1, n1
        mask1(int(x1(2,i))) = .false.
    enddo

    do i = 1, n2
        mask2(int(x2(2,i))) = .false.
    enddo

    a0 = 0.0d0
    g1 = sqrt(2.0d0 * pi)/ang_norm2

    do m = 1, order
        s(m) = g1 * exp(-(t_width * m)**2 / 2.0d0)
    enddo

    inv_width = -1.0d0 / (4.0d0 * d_width**2)

    maxgausdist2 = (8.0d0 * d_width)**2

    aadist = 1.0d0

    do m_1 = 2, N1

        if (X1(1, m_1) > cut_distance) exit

        do m_2 = 2, N2

            if (X2(1, m_2) > cut_distance) exit

            r2 = (X2(1,m_2) - X1(1,m_1))**2

            if (r2 < maxgausdist2) then

                d = exp(r2 * inv_width ) * pd(int(x1(2,m_1)), int(x2(2,m_2)))

                angular = a0 * a0
                dihedral = a0 * a0

                do m = 1, order

                    ang_temp = 0.0d0
                    dihedral_temp = 0.0d0

                    do p11 = 1, pmax1
                        if (mask1(p11)) cycle
                        cos1_temp = cos1(p11,m,m_1)
                        sin1_temp = sin1(p11,m,m_1)

                        do p21 = 1, pmax2
                            if (mask2(p21)) cycle

                            ang_temp = ang_temp + (cos1_temp * cos2(p21,m,m_2) &
                                & + sin1_temp * sin2(p21,m,m_2)) * pd(p21,p11)      

                            do p12 = 1, pmax1
                                if (mask1(p12)) cycle

                                do p22 = 1, pmax2
                                    if (mask2(p22)) cycle
                                    dihedral_temp = dihedral_temp + (cos14(p11, p12, m, m_1) * cos24(p21,p22,m,m_2) &
                                        & + sin14(p11, p12, m, m_1) * sin24(p21,p22,m,m_2)) * pd(p12,p22) * pd(p21,p11)
                                enddo 
                            enddo 
                        enddo 
                    enddo 

                    angular = angular + ang_temp * s(m)
                    dihedral = dihedral + dihedral_temp * s(m)

                enddo

                aadist = aadist + d * (ksi1(m_1) * ksi2(m_2) * distance_scale &
                    & + angular * angular_scale + dihedral * dihedral_scale)

            end if
        end do
    end do

    aadist = aadist * pd(int(x1(2,1)), int(x2(2,1)))

    deallocate(mask1)
    deallocate(mask2)
end function atomic_distl2


end module fchl_utils



subroutine fget_symmetric_kernels_fchl(x1, n1, nneigh1, sigmas, nm1, nsigmas, &
    & t_width, d_width, cut_distance, order, pd, &
    & distance_scale, angular_scale, dihedral_scale, &
    & distance_power, angular_power, dihedral_power, &
    & kernels)

    use fchl_utils, only: atomic_distl2, calc_angle, calc_ksi3, calc_dihedral, calc_ksi4, &
        & cross_product

    implicit none

    ! FCHL descriptors for the training set, format (i,j_1,5,m_1)
    double precision, dimension(:,:,:,:), intent(in) :: x1

    ! List of numbers of atoms in each molecule
    integer, dimension(:), intent(in) :: n1

    ! Number of neighbors for each atom in each compound
    integer, dimension(:,:), intent(in) :: nneigh1

    ! Sigma in the Gaussian kernel
    double precision, dimension(:), intent(in) :: sigmas

    ! Number of molecules
    integer, intent(in) :: nm1

    ! Number of sigmas
    integer, intent(in) :: nsigmas

    double precision, intent(in) :: t_width
    double precision, intent(in) :: d_width 
    double precision, intent(in) :: cut_distance
    integer, intent(in) :: order
    double precision, intent(in) :: distance_scale
    double precision, intent(in) :: angular_scale
    double precision, intent(in) :: dihedral_scale
    
    double precision, intent(in) :: angular_power
    double precision, intent(in) :: dihedral_power
    double precision, intent(in) :: distance_power

    ! -1.0 / sigma^2 for use in the kernel
    double precision, dimension(nsigmas) :: inv_sigma2

    double precision, dimension(:,:), intent(in) :: pd

    ! Resulting alpha vector
    double precision, dimension(nsigmas,nm1,nm1), intent(out) :: kernels

    ! Internal counters
    integer :: i, j, k, l, ni, nj
    integer :: a, b, m, n

    ! Temporary variables necessary for parallelization
    double precision :: l2dist
    double precision, allocatable, dimension(:,:) :: atomic_distance

    ! Pre-computed terms in the full distance matrix
    double precision, allocatable, dimension(:,:) :: selfl21

    ! Pre-computed terms
    double precision, allocatable, dimension(:,:,:) :: ksi1

    double precision, allocatable, dimension(:,:,:,:,:) :: sinp1
    double precision, allocatable, dimension(:,:,:,:,:) :: cosp1

    double precision, allocatable, dimension(:,:,:,:,:,:) :: sinp14
    double precision, allocatable, dimension(:,:,:,:,:,:) :: cosp14

    ! Value of PI at full FORTRAN precision.
    double precision, parameter :: pi = 4.0d0 * atan(1.0d0)

    ! counter for periodic distance
    integer :: pj, pk, pl
    integer :: pmax1
    integer :: nneighi
    double precision :: theta, sin_theta
    double precision :: dihedral1

    double precision, dimension(3) :: vj, vk, vl, vxjk
    double precision :: sin_m, cos_m

    double precision :: ang_norm2

    double precision :: ksi3
    double precision :: ksi4

    ang_norm2 = 0.0d0

    do n = -10000, 10000
        ang_norm2 = ang_norm2 + exp(-((t_width * n)**2)) &
            & * (2.0d0 - 2.0d0 * cos(n * pi))
    end do

    ang_norm2 = sqrt(ang_norm2 * pi) * 2.0d0

    pmax1 = 0

    do a = 1, nm1
        pmax1 = max(pmax1, int(maxval(x1(a,1,2,:n1(a)))))
    enddo

    inv_sigma2(:) = -1.0d0 / (sigmas(:))**2

    allocate(ksi1(nm1, maxval(n1), maxval(nneigh1)))

    ksi1 = 0.0d0

    !$OMP PARALLEL DO PRIVATE(ni, nneighi)
    do a = 1, nm1
        ni = n1(a)
        do i = 1, ni
            nneighi = nneigh1(a, i)
            do j = 2, nneighi
                ksi1(a, i, j) = 1.0d0 / x1(a,i,1,j)**(distance_power)
            enddo
        enddo
    enddo
    !$OMP END PARALLEL DO

    allocate(cosp1(nm1, maxval(n1), pmax1, order, maxval(nneigh1)))
    allocate(sinp1(nm1, maxval(n1), pmax1, order, maxval(nneigh1)))

    cosp1 = 0.0d0
    sinp1 = 0.0d0

    !$OMP PARALLEL DO PRIVATE(ni, nneighi, ksi3, pj, pk, theta, cos_m, sin_m) REDUCTION(+:cosp1,sinp1)
    do a = 1, nm1
        ni = n1(a)

        do i = 1, ni
            nneighi = nneigh1(a, i)

            do j = 2, nneighi
                do k = j+1, nneighi

                    ksi3 = calc_ksi3(X1(a,i,:,:), j, k, angular_power)
                    theta = calc_angle(x1(a, i, 3:5, j), &
                        &  x1(a, i, 3:5, 1), x1(a, i, 3:5, k))

                    pk = int(x1(a,i,2,k))
                    pj = int(x1(a,i,2,j))

                    do m = 1, order

                        cos_m = (cos(m * theta) - cos((theta + pi) * m))*ksi3
                        sin_m = (sin(m * theta) - sin((theta + pi) * m))*ksi3

                        cosp1(a, i, pk, m, j) = cosp1(a, i, pk, m, j) + cos_m
                        sinp1(a, i, pk, m, j) = sinp1(a, i, pk, m, j) + sin_m

                        cosp1(a, i, pj, m, k) = cosp1(a, i, pj, m, k) + cos_m
                        sinp1(a, i, pj, m, k) = sinp1(a, i, pj, m, k) + sin_m

                    enddo
                enddo
            enddo
        enddo
    enddo
    !$OMP END PARALLEL DO

    allocate(cosp14(nm1, maxval(n1), pmax1, pmax1, order, maxval(nneigh1)))
    allocate(sinp14(nm1, maxval(n1), pmax1, pmax1, order, maxval(nneigh1)))

    do a = 1, nm1
        ni = n1(a)

        do i = 1, ni
            nneighi = nneigh1(a, i)

            do j = 2, nneighi
                ! do k = j+1, nneighi
                !     do l = k+1, nneighi
                do k = 2, nneighi
                    do l = 2, nneighi

                        if ((j == k).or.(j == l).or.(k == l)) cycle

                        ! dihedral1 = calc_dihedral(x1(a, i, 3:5, 1), x1(a, i, 3:5, j), x1(a, i, 3:5, k), x1(a, i, 3:5, l))

                        Vj = x1(a, i, 3:5, j) - x1(a, i, 3:5, 1)
                        Vk = x1(a, i, 3:5, k) - x1(a, i, 3:5, 1)
                        Vl = x1(a, i, 3:5, l) - x1(a, i, 3:5, 1)

                        vxjk = cross_product(vj, vk)
                        sin_theta = dot_product(vl, vxjk)/(norm2(vl) * norm2(vxjk))

                        if (sin_theta > 1.0d0)  sin_theta = 1.0d0
                        if (sin_theta < -1.0d0) sin_theta = -1.0d0

                        theta = asin(sin_theta)

                        ksi4 = calc_ksi4(x1(a, i, 3:5, 1), &
                                       & x1(a, i, 3:5, j), &
                                       & x1(a, i, 3:5, k), &
                                       & x1(a, i, 3:5, l), dihedral_power)
                   
                        pj =  int(x1(a,i,2,j))

                        pk =  int(x1(a,i,2,k))
                        pl =  int(x1(a,i,2,l))

                        do m = 1, order

                            cos_m = (cos(m * theta) - cos((theta + pi) * m))*ksi4
                            sin_m = (sin(m * theta) - sin((theta + pi) * m))*ksi4

                            cosp14(a, i, pk, pl, m, j) = cosp14(a, i, pk, pl, m, j) + cos_m
                            sinp14(a, i, pk, pl, m, j) = sinp14(a, i, pk, pl, m, j) + sin_m


                        enddo

                    enddo
                enddo
            enddo
        enddo
    enddo


    allocate(selfl21(nm1, maxval(n1)))

    !$OMP PARALLEL DO PRIVATE(ni)
    do a = 1, nm1
        ni = n1(a)
        do i = 1, ni
            selfl21(a,i) = atomic_distl2(x1(a,i,:,:), x1(a,i,:,:), &
                & nneigh1(a,i), nneigh1(a,i), ksi1(a,i,:), ksi1(a,i,:), &
                & sinp1(a,i,:,:,:), sinp1(a,i,:,:,:), &
                & cosp1(a,i,:,:,:), cosp1(a,i,:,:,:), &
                & sinp14(a,i,:,:,:,:), sinp14(b,j,:,:,:,:), &
                & cosp14(a,i,:,:,:,:), cosp14(b,j,:,:,:,:), &
                & t_width, d_width, cut_distance, order, & 
                & pd, ang_norm2,distance_scale, angular_scale, dihedral_scale)
        enddo
    enddo
    !$OMP END PARALLEL DO

    allocate(atomic_distance(maxval(n1), maxval(n1)))

    kernels(:,:,:) = 0.0d0
    atomic_distance(:,:) = 0.0d0

    !$OMP PARALLEL DO schedule(dynamic) PRIVATE(l2dist,atomic_distance,ni,nj)
    do b = 1, nm1
        nj = n1(b)
        do a = b, nm1
            ni = n1(a)

            atomic_distance(:,:) = 0.0d0

            do i = 1, ni
                do j = 1, nj

                    l2dist = atomic_distl2(x1(a,i,:,:), x1(b,j,:,:), &
                        & nneigh1(a,i), nneigh1(b,j), ksi1(a,i,:), ksi1(b,j,:), &
                        & sinp1(a,i,:,:,:), sinp1(b,j,:,:,:), &
                        & cosp1(a,i,:,:,:), cosp1(b,j,:,:,:), &
                        & sinp14(a,i,:,:,:,:), sinp14(b,j,:,:,:,:), &
                        & cosp14(a,i,:,:,:,:), cosp14(b,j,:,:,:,:), &
                        & t_width, d_width, cut_distance, order, &
                        & pd, ang_norm2, distance_scale, angular_scale, dihedral_scale)

                    l2dist = selfl21(a,i) + selfl21(b,j) - 2.0d0 * l2dist
                    atomic_distance(i,j) = l2dist

                enddo
            enddo

            do k = 1, nsigmas
                kernels(k, a, b) =  sum(exp(atomic_distance(:ni,:nj) &
                    & * inv_sigma2(k)))
                kernels(k, b, a) = kernels(k, a, b)
            enddo

        enddo
    enddo
    !$OMP END PARALLEL DO

    deallocate(atomic_distance)
    deallocate(selfl21)
    deallocate(ksi1)
    deallocate(cosp1)
    deallocate(sinp1)
    deallocate(cosp14)
    deallocate(sinp14)

end subroutine fget_symmetric_kernels_fchl