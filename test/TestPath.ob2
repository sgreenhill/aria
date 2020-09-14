MODULE TestPath;

IMPORT 
	T := Tests,
	Path := arPath;

BEGIN
	T.Begin("TestPath");

	T.StringF(Path.DirName, "/a/b/c/file.ext", "/a/b/c");
	T.StringF(Path.BaseName, "/a/b/c/file.ext", "file.ext");
	T.StringF(Path.ExtName, "/a/b/c/file.ext", ".ext");

	T.StringF(Path.DirName, "file.ext", "");
	T.StringF(Path.BaseName, "/a/b/c/", "");
	T.StringF(Path.ExtName, "file", "");
	T.StringF(Path.ExtName, "file.ext/", "");

	T.StringF(Path.DirName, "", "");
	T.StringF(Path.BaseName, "", "");
	T.StringF(Path.ExtName, "", "");

	T.End;
END TestPath.
