USE SistemaFaculdade;

CREATE TABLE Aluno
(

	Nome			VARCHAR (100) NOT NULL,
	CPF				VARCHAR (15) NOT NULL,
	RA				VARCHAR (15) NOT NULL,
	Curso			VARCHAR (50) NOT NULL,
	Sexo			VARCHAR (10),
	DataNasc		DATE,
	 
	CONSTRAINT PK_Aluno PRIMARY KEY (RA)

);


CREATE TABLE Disciplina
(

	NomeDisciplina	VARCHAR	(50) NOT NULL,
	Codigo		    VARCHAR (20) NOT NULL,
	CargaHoraria	DECIMAL (5,2),
	Descricao		VARCHAR (200),

	CONSTRAINT PK_Disciplina PRIMARY KEY (Codigo)

);


CREATE TABLE Matricula
(

	RA			    VARCHAR (15) NOT NULL,
	Codigo			VARCHAR (20) NOT NULL,
	Nota1			DECIMAL(4,2),
	Nota2			DECIMAL (4,2),
	NotaSub			DECIMAL (4,2),
	Media			DECIMAL (4,2),
	Faltas			INT,
	Situacao		VARCHAR (25),
	Ano				INT,
	Semestre		INT,
	

	CONSTRAINT FK_MatriculaAluno		FOREIGN KEY (RA)		REFERENCES Aluno (RA),
	CONSTRAINT FK_MatriculaDisciplina	FOREIGN KEY (Codigo)		REFERENCES Disciplina (Codigo)

);



INSERT INTO Aluno 
VALUES ('Vinicius', '506.016.088-77', '20180310016', 'Ciencia da Computacao', 'Masculino', '2003-08-16'),
	('Lai', '510.010.077-77', '20180310010', 'Educacao Fisica', 'Masculino', '2002-02-10'),
	('Roger Guedes', '123.009.999-23', '20180310023', 'Educacao Fisica', 'Masculino', '2003-01-23')


INSERT INTO Disciplina
VALUES ('Calculo II', 'UFSCCP/CC-CAL02', 60, 'Disciplina de Calculo II para o curso de Ciencia da Computacao'),
	('Anatomia Humana I', 'UFSCCP/EF-AH01', 80, 'Disciplina de Anatomia Humana I para o curso de Educacao Fisica'),
	('Geometria Analitica e Algebra Linear II', 'UFSCCP/CC-GAAL02', 70, 'Disciplina de Geometria Analitica e Algebra Linear II para o curso de Ciencia da Computacao'),
	('Ergonomia I', 'UFSCCP/EF-ERG01', 80, 'Disciplina de Ergonomia I para o curso de Educacao Fisica')


INSERT INTO Matricula (RA, Codigo, Ano, Semestre, Nota1, Nota2, Media, Faltas)
VALUES ('20180310016','UFSCCP/CC-CAL02', 2021, 2, 3.25, 4.5, (3.25 + 4.0) / 2, 10),
	('20180310016', 'UFSCCP/CC-GAAL02', 2021, 2, 8.25, 9.5, (8.25 + 9.50) / 2, 3),
	('20180310010', 'UFSCCP/EF-AH01', 2021, 2, 3.25, 5.0, (3.25 + 5.0) / 2, 5),
	('20180310010', 'UFSCCP/EF-ERG01', 2021, 2, 7.25, 5.5, (7.25 + 5.5) / 2, 10),
	('20180310023', 'UFSCCP/EF-AH01', 2021, 2, 9.25,5.5, (9.25 + 5.50) / 2, 4),
	('20180310023', 'UFSCCP/EF-ERG01', 2021, 2, 5.25, 5.5, (5.25 + 5.50) / 2, 25)

update Matricula set NotaSub = 1 where RA = '20180310010' AND Codigo = 'UFSCCP/EF-AH01'


GO
ALTER PROCEDURE MediaComSubstitutivaPROC
@RA				VARCHAR (15),
@CODIGO			VARCHAR (20)
AS
BEGIN 

	DECLARE @NOTA1 DECIMAL (4,2), @NOTA2 DECIMAL (4,2), @NOTASUB DECIMAL (4,2)

	SELECT @NOTA1 = Nota1, @NOTA2 = Nota2, @NOTASUB = NotaSub FROM Matricula WHERE RA = @RA AND Codigo = @CODIGO

	IF @NOTA1 > @NOTA2 AND @NOTASUB != NULL
	BEGIN
		
		UPDATE Matricula SET Media = (@NOTA1 + @NOTASUB) / 2 WHERE Codigo = @CODIGO AND RA = @RA

	END

	ELSE IF @NOTA1 < @NOTA2 AND @NOTASUB != NULL
	BEGIN
		
		UPDATE Matricula SET Media = (@NOTA2 + @NOTASUB) / 2 WHERE Codigo = @CODIGO AND RA = @RA

	END

END
GO

EXECUTE MediaComSubstitutivaPROC '20180310010', 'UFSCCP/EF-AH01'


-------------------------------------------------------

GO
ALTER PROCEDURE AtualizaSituacaoPROC
@RA				VARCHAR (15),
@CODIGO			VARCHAR (20),
@ANO			INT,
@SEMESTRE		INT

AS
BEGIN

	DECLARE @CARGAHORARIA DECIMAL (5,2), @MEDIA DECIMAL (4,2), @FALTAS INT
	SELECT @CARGAHORARIA = CargaHoraria FROM Disciplina WHERE Codigo = @CODIGO
	SELECT @MEDIA = Media, @FALTAS = Faltas FROM Matricula WHERE Codigo = @CODIGO AND RA = @RA AND Semestre = @SEMESTRE AND Ano = @ANO


	IF @FALTAS / @CARGAHORARIA > 0.25
	BEGIN

		UPDATE Matricula SET Situacao = 'REPROVADO POR FALTA' WHERE Codigo = @CODIGO AND RA = @RA AND Semestre = @SEMESTRE AND Ano = @ANO

	END

	ELSE IF @MEDIA < 5
	BEGIN
		
		UPDATE Matricula SET Situacao = 'REPROVADO POR NOTA' WHERE Codigo = @CODIGO AND RA = @RA AND Semestre = @SEMESTRE AND Ano = @ANO

	END

	ELSE IF @MEDIA >= 5
	BEGIN

		UPDATE Matricula SET Situacao = 'APROVADO' WHERE Codigo = @CODIGO AND RA = @RA AND Semestre = @SEMESTRE AND Ano = @ANO

	END

END

GO

EXECUTE AtualizaSituacaoPROC '20180310016','UFSCCP/CC-CAL02', 2021, 2
EXECUTE AtualizaSituacaoPROC '20180310016','UFSCCP/CC-GAAL02', 2021, 2
EXECUTE AtualizaSituacaoPROC '20180310010','UFSCCP/EF-AH01', 2021, 2
EXECUTE AtualizaSituacaoPROC '20180310010','UFSCCP/EF-ERG01', 2021, 2
EXECUTE AtualizaSituacaoPROC '20180310023','UFSCCP/EF-AH01', 2021, 2
EXECUTE AtualizaSituacaoPROC '20180310023','UFSCCP/EF-ERG01', 2021, 2


---------------------------------------------------------


GO
ALTER PROCEDURE ConsultaAlunosDisciplinaPROC
@CODIGO VARCHAR (20),
@ANO INT
AS
BEGIN

	SELECT Disciplina.NomeDisciplina, Matricula.Codigo, Aluno.Nome, Matricula.RA, Nota1, Nota2, NotaSub, Media, Faltas, Situacao FROM Matricula 
	INNER JOIN Aluno ON Matricula.RA = Aluno.RA
	INNER JOIN Disciplina ON Matricula.Codigo = Disciplina.Codigo
	WHERE Matricula.Codigo = @CODIGO AND Ano = @ANO

END
GO

EXECUTE ConsultaAlunosDisciplinaPROC 'UFSCCP/EF-ERG01', 2021
EXECUTE ConsultaAlunosDisciplinaPROC 'UFSCCP/EF-AH01', 2021
EXECUTE ConsultaAlunosDisciplinaPROC 'UFSCCP/CC-GAAL01', 2021
EXECUTE ConsultaAlunosDisciplinaPROC 'UFSCCP/CC-CAL01', 2021



---------------------------------------------------------


GO
ALTER PROCEDURE ConsultaAlunosPROC
@RA VARCHAR (20),
@ANO INT, 
@SEMESTRE INT
AS
BEGIN

	SELECT Aluno.Nome, Matricula.RA, Disciplina.NomeDisciplina, Matricula.Codigo, Nota1, Nota2, NotaSub, Media, Faltas, Situacao, Ano, Semestre FROM Matricula 
	INNER JOIN Aluno ON Matricula.RA = Aluno.RA
	INNER JOIN Disciplina ON Matricula.Codigo = Disciplina.Codigo
	WHERE Matricula.RA = @RA AND Ano = @ANO AND Semestre = @SEMESTRE

END
GO

EXECUTE ConsultaAlunosPROC '20180310016', 2021, 2
EXECUTE ConsultaAlunosPROC '20180310010', 2021, 2
EXECUTE ConsultaAlunosPROC '20180310023', 2021, 2


---------------------------------------------------------


GO
ALTER PROCEDURE ConsultaReprovadosPorNotaPROC
@SITUACAO VARCHAR (25)
AS
BEGIN

	SELECT Aluno.Nome, Matricula.RA, Disciplina.NomeDisciplina, Matricula.Codigo, Nota1, Nota2, NotaSub, Media,  Situacao, Ano FROM Matricula 
	INNER JOIN Aluno ON Matricula.RA = Aluno.RA
	INNER JOIN Disciplina ON Matricula.Codigo = Disciplina.Codigo
	WHERE Situacao = @SITUACAO
END
GO

EXECUTE ConsultaReprovadosPorNotaPROC 'REPROVADO POR NOTA'




select * from Aluno
select * from Disciplina
select * from Matricula


delete from Matricula
delete from Disciplina
delete from Aluno

DROP TABLE Matricula
DROP TABLE Disciplina
DROP TABLE Aluno
