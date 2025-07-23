import { IExecuteFunctions, NodeOperationError } from 'n8n-workflow';
import { getTempFile, runFfmpeg, verifyFfmpegAvailability } from '../utils';
import ffmpeg = require('fluent-ffmpeg');
import * as fs from 'fs-extra';

export async function executeConcatenateAudio(
	this: IExecuteFunctions,
	audioPaths: string[],
	outputFormat: string,
	itemIndex: number,
): Promise<string> {
	// Verify FFmpeg is available before proceeding
	try {
		verifyFfmpegAvailability();
	} catch (error) {
		throw new NodeOperationError(
			this.getNode(),
			`FFmpeg is not available: ${(error as Error).message}`,
			{ itemIndex }
		);
	}

	if (!audioPaths || audioPaths.length === 0) {
		throw new NodeOperationError(
			this.getNode(),
			'No audio files provided for concatenation',
			{ itemIndex }
		);
	}

	if (audioPaths.length === 1) {
		throw new NodeOperationError(
			this.getNode(),
			'At least 2 audio files are required for concatenation',
			{ itemIndex }
		);
	}

	// Verify all input files exist
	for (const audioPath of audioPaths) {
		if (!await fs.pathExists(audioPath)) {
			throw new NodeOperationError(
				this.getNode(),
				`Audio file not found: ${audioPath}`,
				{ itemIndex }
			);
		}
	}

	const outputPath = getTempFile(`.${outputFormat}`);
	
	try {
		// Create a temporary file list for FFmpeg concat demuxer
		const fileListPath = getTempFile('.txt');
		const fileListContent = audioPaths
			.map(audioPath => `file '${audioPath.replace(/'/g, "'\\''")}'`) // Escape single quotes
			.join('\n');
		
		await fs.writeFile(fileListPath, fileListContent, 'utf8');

		// Use FFmpeg concat demuxer for lossless concatenation
		const command = ffmpeg()
			.input(fileListPath)
			.inputOptions(['-f', 'concat', '-safe', '0'])
			.audioCodec('copy') // Use copy codec for lossless concatenation when possible
			.output(outputPath);

		// If output format is different from input, we need to re-encode
		if (outputFormat !== 'mp3') {
			command.audioCodec('aac'); // Use AAC for non-MP3 formats
		}

		await runFfmpeg(command);

		// Clean up the temporary file list
		await fs.remove(fileListPath).catch(() => {
			// Ignore cleanup errors
		});

		// Verify output file was created
		if (!await fs.pathExists(outputPath)) {
			throw new NodeOperationError(
				this.getNode(),
				'Failed to create concatenated audio file',
				{ itemIndex }
			);
		}

		return outputPath;

	} catch (error) {
		// Clean up output file if it exists
		await fs.remove(outputPath).catch(() => {
			// Ignore cleanup errors
		});

		if (error instanceof NodeOperationError) {
			throw error;
		}

		throw new NodeOperationError(
			this.getNode(),
			`Audio concatenation failed: ${(error as Error).message}`,
			{ itemIndex }
		);
	}
}
