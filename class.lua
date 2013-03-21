--$Id$
--�������

--��ȡһ��class�ĸ���
function Super(TmpClass)
	return TmpClass.__SuperClass
end

--�ж�һ��class���߶����Ƿ�
function IsSub(clsOrObj, Ancestor)
	local Temp = clsOrObj
	while  1 do
		local mt = getmetatable(Temp)
		if mt then
			Temp = mt.__index
			if Temp == Ancestor then
				return true
			end
		else
			return false
		end
	end
end

--�� AttachToClass ���Ӧ
function GetObjClass(Obj)
	local mt = getmetatable(Obj)
	if mt then
		return mt.__index
	end
end

--ʹ��metatable��ʽ�̳�
function InheritWithMetatable(Base, o)
	o = o or {}
	setmetatable(o, {__index = Base})
	o.__SuperClass = Base
	return o
end

--ʹ��Copy��ʽʵ�ּ̳У�Ĭ�ϼ̳з�ʽ
function InheritWithCopy(Base, o)
	o = o or {}

	--û�ж�table���������������������table����Ӧ����init�����г�ʼ��
	--��Ӧ�ð�һ��table���Էŵ�class�Ķ�����

	if not Base.__SubClass then
		Base.__SubClass = {}
		setmetatable(Base.__SubClass, {__mode="v"})
	end
	table.insert(Base.__SubClass, o)

	for k, v in pairs(Base) do
		if not o[k] then
			o[k]=v
		end
	end
	o.__SubClass = nil
	o.__SuperClass = Base

	return o
end

--��ʱû��һ���ȽϺõķ�������ֹ��Class��table����һ��ʵ����ʹ��
--�������һ��Class��ʱ��һ��Ҫ���������ʵ����������
clsObject = {
		--���������Ƿ���һ������ or Class or ��ͨtable
		__ClassType = "<base class>",
		Inherit = InheritWithCopy,
	}
		

function clsObject:AttachToClass(Obj)
	setmetatable(Obj, {__ObjectType="<base object", __index = self})
	return Obj
end


function clsObject:New(...)
	local o = {}

	--û�г�ʼ����������ԣ���������Ӧ����init��������ʾ��ʼ��
	--��������࣬Ӧ�����Լ���init�������ȵ��ø����init����

	self:AttachToClass(o)

	if o.__init__ then
		o:__init__(...)
	end
	return o
end

function clsObject:__init__()
	--nothing
end

function clsObject:IsClass()
	return true
end

function clsObject:GetDest()
	return self.__DestroyTime
end

function clsObject:Destroy()
	--���ж����ͷŵ�ʱ��ɾ��callout
	CALLOUT.RemoveAll(self)
	self.__DestroyTime = os.time()
end

