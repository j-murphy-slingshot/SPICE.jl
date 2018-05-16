export
    ccifrm,
    cgv2el,
    cidfrm,
    ckcls,
    ckcov,
    ckcov!,
    ckobj,
    ckobj!,
    ckgp,
    ckgpav,
    ckopn,
    ckw01,
    clight

"""
    ccifrm(frclss, clssid)

Return the frame name, frame ID, and center associated with a given frame class and class ID.

### Arguments ###

- `frclss`: Class of frame
- `clssid`: Class ID of frame

### Output ###

Return the tuple `(frcode, frname, center)`.

- `frcode`: ID code of the frame
- `frname`: Name of the frame
- `center`: ID code of the center of the frame

### References ###

- [NAIF Documentation](https://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/cspice/ccifrm_c.html)
"""
function ccifrm(frclss, clssid)
    lenout = 33
    frcode = Ref{SpiceInt}()
    frname = Array{UInt8}(lenout)
    center = Ref{SpiceInt}()
    found = Ref{SpiceBoolean}()
    ccall((:ccifrm_c, libcspice), Void,
          (SpiceInt, SpiceInt, SpiceInt, Ref{SpiceInt}, Ptr{UInt8}, Ref{SpiceInt}, Ref{SpiceBoolean}),
          frclss, clssid, lenout, frcode, frname, center, found,
         )
    handleerror()
    found[] == 0 && throw(SpiceException("No frame with class $frclss and class ID $clssid found."))
    frcode[], unsafe_string(pointer(frname)), center[]
end

"""
    cgv2el(center, vec1, vec2)

Form a CSPICE ellipse from a center vector and two generating vectors.

### Arguments ###

- `center`: Center vector
- `vec1`: Generating vector
- `vec2`: Generating vector

### Output ###

The CSPICE ellipse defined by the input vectors.

### References ###

- [NAIF Documentation](https://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/cspice/cgv2el_c.html)
"""
function cgv2el(center, vec1, vec2)
    ellipse = Ellipse()
    ccall((:cgv2el_c, libcspice), Void,
        (Ptr{SpiceDouble}, Ptr{SpiceDouble}, Ptr{SpiceDouble}, Ref{Ellipse}),
        center, vec1, vec2, ellipse)
    ellipse
end

"""
    ckcov(ck, idcode, needav, level, tol, timsys)

Find the coverage window for a specified object in a specified CK file.

### Arguments ###

- `ck`: Name of CK file
- `idcode`: ID code of object
- `needav`: Flag indicating whether angular velocity is needed
- `level`: Coverage level:  "SEGMENT" OR "INTERVAL"
- `tol`: Tolerance in ticks
- `timsys`: Time system used to represent coverage

### Output ###

Window giving coverage for `idcode`

### References ###

- [NAIF Documentation](https://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/cspice/ckcov_c.html)
"""
function ckcov(ck, idcode, needav, level, tol, timsys)
    cover = SpiceDoubleCell(20000)
    ckcov!(ck, idcode, needav, level, tol, timsys, cover)
end

"""
    ckcov!(ck, idcode, needav, level, tol, timsys, cover)

Find the coverage window for a specified object in a specified CK file.

### Arguments ###

- `ck`: Name of CK file
- `idcode`: ID code of object
- `needav`: Flag indicating whether angular velocity is needed
- `level`: Coverage level:  "SEGMENT" OR "INTERVAL"
- `tol`: Tolerance in ticks
- `timsys`: Time system used to represent coverage
- `cover`: Window giving coverage for `idcode`. Data already present in `cover`
    will be combined with coverage found for the object designated by `idcode`
    in the file `ck`.

### References ###

- [NAIF Documentation](https://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/cspice/ckcov_c.html)
"""
function ckcov!(ck, idcode, needav, level, tol, timsys, cover)
    ccall((:ckcov_c, libcspice), Void,
        (Cstring, SpiceInt, SpiceBoolean, Cstring, SpiceDouble, Cstring,
            Ref{Cell{SpiceDouble}}),
        ck, idcode, needav, level, tol, timsys, cover.cell)
    handleerror()
    cover
end

"""
    ckobj(ck)

Find the set of ID codes of all objects in a specified CK file.

### Arguments ##

- `ck`: Name of CK file

### Output ###

Set of ID codes of objects in CK file.

### References ###

- [NAIF Documentation](https://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/cspice/ckobj_c.html)
"""
function ckobj(ck)
    ids = SpiceIntCell(1000)
    ckobj!(ck, ids)
end

"""
    ckobj!(ck, ids)

Find the set of ID codes of all objects in a specified CK file.

### Arguments ##

- `ck`: Name of CK file
- `ids`: Set of ID codes of objects in CK file. Data already present in 
    `ids` will be combined with ID code set found for the file `ck`.

### References ###

- [NAIF Documentation](https://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/cspice/ckobj_c.html)
"""
function ckobj!(ck, ids)
    ccall((:ckobj_c, libcspice), Void, (Cstring, Ref{Cell{SpiceInt}}),
        ck, ids.cell)
    handleerror()
    ids
end

"""
    cidfrm(cent)

Retrieve frame ID code and name to associate with a frame center.

### Arguments ###

- `cent`: ID code for an object for which there is a preferred reference frame

### Output ###

Returns the tuple `(frcode, frname)`

- `frcode`: The ID code of the frame associated with `cent`
- `frname`: The name of the frame with ID `frcode`

### References ###

- [NAIF Documentation](https://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/cspice/cidfrm_c.html)
"""
function cidfrm(cent)
    lenout = 33
    frcode = Ref{SpiceInt}()
    frname = Array{UInt8}(lenout)
    found = Ref{SpiceBoolean}()
    ccall((:cidfrm_c, libcspice), Void, (SpiceInt, SpiceInt, Ref{SpiceInt}, Ptr{UInt8}, Ref{SpiceBoolean}),
          cent, lenout, frcode, frname, found)
    found[] == 0 && throw(SpiceException("No frame associated with body $cent found."))
    frcode[], unsafe_string(pointer(frname))
end

"""
    ckopn(fname, ifname="CK_file", ncomch=0)

Open a new CK file, returning the handle of the opened file.

### Arguments ###

- `fname`: The name of the CK file to be opened
- `ifname="CK_file"`: The internal filename for the CK, default is "CK_file"
- `ncomch=0`: The number of characters to reserve for comments, default is zero

### Output ###

- `handle`: The handle of the opened CK file

### References ###

- [NAIF Documentation](https://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/cspice/ckopn_c.html)
"""
function ckopn(fname, ifname="CK_file", ncomch=0)
    handle = Ref{SpiceInt}()
    ccall((:ckopn_c, libcspice), Void, (Cstring, Cstring, SpiceInt, Ref{SpiceInt}),
          fname, ifname, ncomch, handle)
    handleerror()
    handle[]
end

"""
    ckcls(handle)

Close an open CK file.

### Arguments ###

- `handle`: Handle of the CK file to be closed

### References ###

- [NAIF Documentation](https://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/cspice/ckcls_c.html)
"""
function ckcls(handle)
    ccall((:ckcls_c, libcspice), Void, (SpiceInt,), handle)
    handleerror()
end

"""
"""
function ckw01(handle, inst, ref, segid, sclkdp, quats, avvs=Matrix(0,0);
               begtim=sclkdp[1], endtim=sclkdp[end])
    nrec = length(sclkdp)
    avflag = length(avvs) > 0 ? 1 : 0
    ccall((:ckw01_c, libcspice), Void,
          (SpiceInt, SpiceDouble, SpiceDouble, SpiceInt, Cstring, SpiceInt, Cstring, SpiceInt,
           Ptr{SpiceDouble}, Ptr{SpiceDouble}, Ptr{SpiceDouble}),
          handle, begtim, endtim, inst, ref, avflag, segid, nrec, sclkdp, quats, avvs)
    handleerror()
end

"""
"""
function ckgp()
end

"""
"""
function ckgpav()
end

"""
    clight()

### Output ###

Returns the speed of light in vacuo (km/sec).
"""
function clight()
    ccall((:clight_c, libcspice), Cdouble, ())
end
