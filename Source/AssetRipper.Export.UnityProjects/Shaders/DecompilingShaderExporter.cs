using AssetRipper.Assets;
using AssetRipper.SourceGenerated.Classes.ClassID_48;

namespace AssetRipper.Export.UnityProjects.Shaders;

/// <summary>
/// Exports shaders using decompilation. Currently falls back to Dummy export.
/// TODO: Integrate USCSandbox (https://github.com/nesrak1/USCSandbox) for actual decompilation.
/// </summary>
public class DecompilingShaderExporter : ShaderExporterBase
{
	public override bool Export(IExportContainer container, IUnityObjectBase asset, string path, FileSystem fileSystem)
	{
		if (asset is not IShader shader)
			return false;

		return ExportShader(shader, path, fileSystem);
	}

	public static bool ExportShader(IShader shader, string path, FileSystem fileSystem)
	{
		using Stream fileStream = fileSystem.File.Create(path);
		using InvariantStreamWriter writer = new(fileStream);
		return ExportShader(shader, writer);
	}

	public static bool ExportShader(IShader shader, TextWriter writer)
	{
		// Fall back to Dummy export for now
		// The UI restriction has been removed so users can select this option
		return DummyShaderTextExporter.ExportShader(shader, writer);
	}
}
