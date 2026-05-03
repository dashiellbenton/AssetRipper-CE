namespace AssetRipper.Import.Configuration;

public record AssetPathOverride(
	long PathID,
	string? OverridePath,
	string? OverrideDirectory,
	string? OverrideName,
	string? OverrideExtension
);
